# Helper function: Same as `$1=$2`, but will only happen if the name
# specified by `$1` is not already set.
# 
# Usage
#   -antigen-set-env VAR_NAME VAR_VALUE
#
# Returns
#   Nothing.
typeset -ga _ANTIGEN_ENV; _ANTIGEN_ENV=()
-antigen-set-default () {
  local arg_name="$1"
  local arg_value="$2"
  _ANTIGEN_ENV+=($arg_name)
  eval "test -z \"\$$arg_name\" && typeset -g $arg_name='$arg_value'"
}
