#!/bin/sh

package_dir=$(dirname -- "$(realpath "$0")")
cd "$package_dir"

source ../../common/github.sh

check_dependencies

echo '--- verifying specter desktop'

package_name='specter_desktop'
repo='cryptoadvance/specter-desktop'
key_fingerprints=(
  '785A2269EE3A9736AC1A4F4C864B7CF9A811FEF7' # http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x785a2269ee3a9736ac1a4f4c864b7cf9a811fef7
)
shasum_filename_pattern='SHA256SUMS'
shasum_signature_filename_pattern="$shasum_filename_pattern.asc"

verify_from_github "$package_name" "$repo" "$key_fingerprints" "$shasum_filename_pattern" "$shasum_signature_filename_pattern"
