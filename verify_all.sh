#!/bin/sh

find packages -name 'verify.sh' -type f -print0 | while IFS= read -r -d '' script; do
  "$script"
  echo
done
