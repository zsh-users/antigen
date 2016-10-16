# Updates _ANTIGEN_INTERACTIVE environment variable to reflect
# if antigen is running in an interactive shell or from sourcing.
#
# This function check ZSH_EVAL_CONTEXT if available or functrace otherwise.
# If _ANTIGEN_INTERACTIVE is set to true it won't re-check again.
#
# Usage
#   -antigen-interactive-mode
#
# Returns
#   Either true or false depending if we are running in interactive mode
-antigen-interactive-mode () {
    # Check if we are in any way running in interactive mode
    if [[ $_ANTIGEN_INTERACTIVE == false ]]; then
        if [[ "$ZSH_EVAL_CONTEXT" =~ "toplevel:*" ]]; then
            _ANTIGEN_INTERACTIVE=true
        elif [[ -z "$ZSH_EVAL_CONTEXT" ]]; then
            zmodload zsh/parameter
            if [[ "${functrace[$#functrace]%:*}" == "zsh" ]]; then
                _ANTIGEN_INTERACTIVE=true
            fi
        fi
    fi

    return _ANTIGEN_INTERACTIVE
}
