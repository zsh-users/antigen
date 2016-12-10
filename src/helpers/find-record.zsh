# Filters _ANTIGEN_BUNDLE_RECORD for $1
#
# Usage
#   -antigen-find-record example/bundle
#
# Returns
#   String if record is found
-antigen-find-record () {
  local bundle=$1
  local _IFS

  # Using typeset in order to support zsh <= 5.0.0
  typeset -a records
  
  if [[ $# -eq 0 ]]; then
    return 1
  fi

  _IFS="$IFS"
  IFS=$'\n'
  records=(${(@f)$(-antigen-echo-record)})
  IFS="$_IFS"
  
  echo "${records[(r)*$bundle*]}"
}
