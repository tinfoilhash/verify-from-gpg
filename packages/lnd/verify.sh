#!/bin/sh

package_dir=$(dirname -- "$(realpath "$0")")
cd "$package_dir"

source ../../common/github.sh

check_dependencies

echo '--- verifying lnd'

package_name='lnd'
repo='lightningnetwork/lnd'
key_fingerprints=(
  'A5B61896952D9FDA83BC054CDC42612E89237182' # https://raw.githubusercontent.com/lightningnetwork/lnd/master/scripts/keys/roasbeef.asc
)
shasum_filename_pattern='manifest-{{NAME}}.txt'
shasum_signature_filename_pattern='manifest-roasbeef-{{NAME}}.sig'

verify_from_github "$package_name" "$repo" "$key_fingerprints" "$shasum_filename_pattern" "$shasum_signature_filename_pattern"
