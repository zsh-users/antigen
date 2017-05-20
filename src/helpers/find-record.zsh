# Filters _ANTIGEN_BUNDLE_RECORD for $1
#
# Usage
#   -antigen-find-record example/bundle
#
# Returns
#   String if record is found
-antigen-find-record () {
  local bundle=$1
  
  if [[ $# -eq 0 ]]; then
    return 1
  fi

  local record=${bundle/\|/\\\|}
  echo "${_ANTIGEN_BUNDLE_RECORD[(r)*$record*]}"
}
