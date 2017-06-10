# This function check ZSH_EVAL_CONTEXT to determine if running in interactive shell. 
#
# Usage
#   -antigen-interactive-mode
#
# Returns
#   Either true or false depending if we are running in interactive mode
-antigen-interactive-mode () {
  WARN "-antigen-interactive-mode: $ZSH_EVAL_CONTEXT \$_ANTIGEN_INTERACTIVE = $_ANTIGEN_INTERACTIVE"
  if [[ $_ANTIGEN_INTERACTIVE != "" ]]; then
    [[ $_ANTIGEN_INTERACTIVE == true ]];
    return
  fi

  [[ "$ZSH_EVAL_CONTEXT" == toplevel* || "$ZSH_EVAL_CONTEXT" == cmdarg* ]];
}
