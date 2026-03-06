config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/verify-from-gpg"
relay='wss://verify-relay.tinfoilhash.com'

npub_hex=$(nak key public "$NSEC")

check_dependencies() {
  commands=(
    'gh'
    'gpg'
    'hq'
    'jaq'
    'nak'
  )

  for command in "${commands[@]}"; do
    if ! type "$command" &> /dev/null; then
      echo "$command not found, exiting"
      exit 1
    fi
  done

  if [ ! -n "${NSEC+set}" ]; then
    echo '$NSEC not set, exiting'
    exit 1
  fi
}

source_state() {
  package_name="$1"

  state_file="$config_dir/$package_name"

  if [ -f "$state_file" ]; then
    source "$state_file"
  else
    mkdir -p "$config_dir"
  fi

  [ -n "${last_release_published_at+set}" ] && limit=30 || limit=3
  : ${last_release_published_at:='1970-01-01T00:00:00Z'}
}

is_published_to_verify() {
  hash="$1"

  nak req -q -k 1063 -a "$npub_hex" -t x="$hash" "$relay" < /dev/null 2>&1 \
  | grep -Fq "$hash"
}

publish_to_verify() {
  filename="$1"
  hash="$2"
  url="$3"
  content_type="$4"
  size="$5"

  nak event -k 1063 -c "$filename" -t x="$hash" -t url="$url" -t m="$content_type" -t size="$size" --sec "$NSEC" "$relay" < /dev/null
}

complete_release() {
  package_name="$1"
  release_dir="$2"
  published_at="$3"

  state_file="$config_dir/$package_name"

  cd ..
  rm -r "$release_dir"

  cat > "$state_file" << EOF
last_release_published_at='$published_at'
EOF
}
