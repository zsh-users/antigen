# Filters _ANTIGEN_BUNDLE_RECORD for $1
#
# Usage
#   -antigen-find-record example/bundle
#
# Returns
#   String if record is found
-antigen-find-record () {
  local bundle=$1
  # Using typeset in order to support zsh <= 5.0.0
  typeset -a records

  local _IFS="$IFS"
  IFS=$'\n'
  records=(${(f)_ANTIGEN_BUNDLE_RECORD})
  IFS="$_IFS"

  echo "${records[(r)*$bundle*]}"
}

