# List instaled bundles either in long (record) or short format
#
# Usage
#    antigen-list [--short|--long]
#
# Returns
#    List of bundles
antigen-list () {
  local format=$1

  # List all currently installed bundles.
  if [[ -z "$_ANTIGEN_BUNDLE_RECORD" ]]; then
    echo "You don't have any bundles." >&2
    return 1
  fi

  -antigen-get-bundles $format
}
