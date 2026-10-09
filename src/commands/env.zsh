# Shows environment variables set up for Antigen
# 
# Usage
#   antigen env
#
# Returns
#   List of environment variables defined by -antigen-set-default with respective values.
antigen-env () {
  local key value
  for key in ${_ANTIGEN_ENV}; do
    value=$(eval echo \$$key)
    echo "$key=$value"
  done
}
