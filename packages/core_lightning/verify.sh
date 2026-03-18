#!/bin/sh

package_dir=$(dirname -- "$(realpath "$0")")
cd "$package_dir"

source ../../common/github.sh

check_dependencies

echo '--- verifying core lightning'

package_name='core_lightning'
repo='ElementsProject/lightning'
key_fingerprints=(
  '15EE8D6CAB0E7F0CF999BFCBD9200E6CD1ADB8F1' # https://raw.githubusercontent.com/ElementsProject/lightning/refs/heads/master/contrib/keys/rustyrussell.txt
  'B731AAC521B013859313F674A26D6D9FE088ED58' # https://raw.githubusercontent.com/ElementsProject/lightning/refs/heads/master/contrib/keys/cdecker.txt
  '30DE693AE0DE9E37B3E7EB6BBFF0F67810C1EED1' # https://raw.githubusercontent.com/ElementsProject/lightning/refs/heads/master/contrib/keys/niftynei.txt
  '04374E42789BBBA9462E4767F3BF63F2747436AB' # https://raw.githubusercontent.com/ElementsProject/lightning/refs/heads/master/contrib/keys/amyers.txt
  '653B19F33DF7EFF3E9D1C94CC3F21EE387FF4CD2' # https://raw.githubusercontent.com/ElementsProject/lightning/refs/heads/master/contrib/keys/pneuroth.txt
  'CE54C6D66B36D459CA4E8FEE951B8D133DD4AF6E' # https://raw.githubusercontent.com/ElementsProject/lightning/refs/heads/master/contrib/keys/sfarooqui.txt
  '0CCA8183C13A2389A9C5FD29BFB015360049CB56' # https://raw.githubusercontent.com/ElementsProject/lightning/refs/heads/master/contrib/keys/sfarooqui.txt
  '7169D26272B50A3F531AA1C2A57AFC231B580804' # https://raw.githubusercontent.com/ElementsProject/lightning/refs/heads/master/contrib/keys/madel.txt
  '616C52F99D0612B2A151B1074129A994AA7E9852' # https://raw.githubusercontent.com/ElementsProject/lightning/refs/heads/master/contrib/keys/cln.txt
  '1A371C2C30645FAA91AA6B7DB643E61284221961' # https://raw.githubusercontent.com/ElementsProject/lightning/refs/heads/master/contrib/keys/sangbida.txt
)
shasum_filename_pattern='SHA256SUMS-{{NAME}}'
shasum_signature_filename_pattern="$shasum_filename_pattern.asc"

verify_from_github "$package_name" "$repo" "$key_fingerprints" "$shasum_filename_pattern" "$shasum_signature_filename_pattern"
