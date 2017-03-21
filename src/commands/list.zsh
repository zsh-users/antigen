# List instaled bundles either in long (record), short or simple format.
#
# Usage
#    antigen-list [--short|--long|--simple]
#
# Returns
#    List of bundles
antigen-list () {
  local format=$1

  # List all currently installed bundles.
  if [[ -z $_ANTIGEN_BUNDLE_RECORD ]]; then
    echo "You don't have any bundles." >&2
    return 1
  fi

  -antigen-get-bundles $format
}
