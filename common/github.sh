source ../../common/common.sh

verify_from_github() {
  package_name="$1"
  repo="$2"
  key_fingerprints="$3"
  shasum_filename_pattern="$4"
  shasum_signature_filename_pattern="$5"

  source_state "$package_name"

  echo '----- checking for gpg keys'

  key_fingerprints_found=false

  for key_fingerprint in "${key_fingerprints[@]}"; do
    if gpg --list-keys "$key_fingerprint"; then
      key_fingerprints_found=true
    fi
  done

  if [ "$key_fingerprints_found" = false ]; then
    echo 'did not find at least one key, exiting'
    exit 1
  fi

  echo '----- getting list of releases'

  releases=$(gh release list --repo "$repo" --exclude-drafts --limit "$limit" --json tagName,publishedAt)

  echo '----- checking for new releases'

  new_releases=$(echo "$releases" | jaq -r "map(select(.publishedAt > \"$last_release_published_at\")) | reverse | .[] | \"\(.tagName),\(.publishedAt)\"")
  new_releases_count=$(printf '%s' "$new_releases" | grep -c '^')

  echo "new releases found: $new_releases_count"

  if [ "$new_releases_count" -eq 0 ]; then
    return
  fi

  echo "$new_releases" | while IFS=',' read -r name published_at; do
    echo "- $name ($published_at)"
  done

  echo "$new_releases" | while IFS=',' read -r name published_at; do
    echo "----- new release: $name ($published_at)"

    echo '------- getting list of assets'

    release_assets=$(gh release view "$name" --repo "$repo" --json assets)

    echo "------- downloading assets to directory: $name"

    mkdir "$name" &> /dev/null
    cd "$name"

    gh release download "$name" --repo "$repo" --skip-existing

    echo '------- verifying gpg signatures'

    shasum_signature_filename="${shasum_signature_filename_pattern//\{\{NAME\}\}/$name}"

    if [ ! -f "$shasum_signature_filename" ]; then
      echo 'file does not exist, skipping'
      complete_release "$package_name" "$name" "$published_at"
      continue
    fi

    if ! gpg --verify "$shasum_signature_filename"; then
      exit 1
    fi

    echo '------- verifying hashes'

    shasum_filename="${shasum_filename_pattern//\{\{NAME\}\}/$name}"

    if [ ! -f "$shasum_filename" ]; then
      echo 'file does not exist, skipping'
      complete_release "$package_name" "$name" "$published_at"
      continue
    fi

    if [ "$shasum_filename" = "$shasum_signature_filename" ]; then
      shasum_manifest=$(gpg --decrypt "$shasum_signature_filename" 2>/dev/null)
    else
      shasum_manifest=$(<"$shasum_filename")
    fi

    shasum_check=$(echo "$shasum_manifest" | shasum --check --ignore-missing)

    echo "$shasum_manifest" | while IFS=' ' read -r hash asterisk_filename; do
      filename=$(echo "$asterisk_filename" | sed 's/^*//')

      echo "------- processing file: $filename"

      if [ ! -f "$filename" ]; then
        echo 'file does not exist, skipping'
        continue
      fi

      if is_published_to_verify "$hash"; then
        echo 'file already verified, skipping'
        continue
      fi

      IFS=',' read -r url content_type size <<< "$(echo "$release_assets" | jaq -r ".assets[] | select(.name == \"$filename\") | \"\(.url),\(.contentType),\(.size)\"")"

      echo "filename: $filename"
      echo "hash: $hash"
      echo "url: $url"
      echo "content type: $content_type"
      echo "size: $size"

      if echo "$shasum_check" | grep -Fxq "$filename: OK"; then
        echo 'verified: yes'
      else
        echo 'verified: no'
        echo 'file not verified, skipping'
        continue
      fi

      echo '------- publishing event'

      if ! publish_to_verify "$filename" "$hash" "$url" "$content_type" "$size"; then
        exit 1
      fi
    done

    complete_release "$package_name" "$name" "$published_at"
  done
}
