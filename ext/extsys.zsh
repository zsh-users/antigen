# Extension system
#
# Provides an extension load mechanism for loading custom code that extends antigen.
#
# This is different than plugins or themes in a way that it actually interacts with
# antigen as it can hook into different antigen commands and internal/private functions.
#
# It provides pre- and post- hooks for any function (currently even outside antigen). Effectively
# executing the pre-function, the function itself and a post-function.
#
# It doesn't short-circuit (meaning it will always call all hooks and the actual command/function).
#
# Usage:
#
#       antigen ext ext-name # loads (ie, sources) the given extension from $ADOTDIR/ext/
#
# These are only meant to be run inside extension definitions:
#
#       # overwrites 'any-antigen-function' (ex, antigen-bundle) with 'extension-hook-function'
#       # which could be any function already defined.
#       # it can hook into pre- or post- events. defaults to pre-.
#       -ext-hook "any-antigen-function" "extension-hook-function" ["pre"|"post"]
#
#       # defined a new autocompletion for the antigen command (ex, antigen logger)
#       -ext-compadd "extension-auto-completion"
#
# The hooks functions receives the same arguments the original function receives.
typeset -A callbacks
local -a hooks; hooks=()

# enable or disable logging
export _EXT_LOGGING_ENABLED=false

# logs a custom message (echo to >&2)
#
# usage:
#   -ext-log "message"          # LOG: message
#   -ext-log -e "error message" # ERROR: error message
#
# enable or disable logging with $_EXT_LOGGING_ENABLED env variable
function -ext-log () {
    local message
    if [[ $1 == "-e" ]]; then
        shift
        message="ERROR: $@"
    else
        message="LOG: $@"
    fi

    if ($_EXT_LOGGING_ENABLED) {
        echo "$message" >&2
    }
}

# function wrapper for -ext-log to display "ERROR: " labeled logs
#
# usage:
#   -ext-log-error "error"  # ERROR: error
function -ext-log-error () {
    -ext-log "-e" "$@"
}

# capture functions providing a pre and post callbacks
#
# usage:
#   -ext-capture "func-name"
#
# captures 'func-name' and registers it into $hooks list
function -ext-capture () {
    local funcname="$1"
    eval "function -captured-$(functions -- $funcname)"

    -ext-log capturing function $funcname
    hooks+=($funcname)

    $funcname () {
        callback="$0"
        call-hooks () {
            local hook_name="$1-$2"
            local names=${callbacks[$hook_name]}
            for hook in ${(s.:.)names}; do
                -ext-log calling hook function $hook for $hook_name
                eval "$hook" "$3"
            done
        }

        # calling pre hooks
        call-hooks "$callback" "pre" "$@"

        # we call the captured function
        -captured-$0 $@

        # calling post hooks
        call-hooks "$callback" "post" "$@"
    }
}

# hooks a particular function
#
# usage:
#   -antigen-hook "antigen-bundle" "antigen-bundle-hook"    # hooks antigen-bundle (pre event)
#   -antigen-hook "antigen-bundle" "antigen-bundle-hook" "post" #hooks antigen-bundle (post event)
#
# if the function to be hooked wasn't captured it captures it with -ext-capture
function -ext-hook () {
    local function_hook="$1"
    local callback_function="$2"
    local event="$3"

    if [ ! "$event" ]; then
        event="pre"
    fi

    local hook_name="$function_hook-$event"

    callbacks[$hook_name]=${callbacks[$hook_name]}"$callback_function:"

    if [[ ! -n "${hooks[(r)$function_hook]}" ]]; then
        -ext-capture $function_hook
    else
        -ext-log already hooked function $function_hook
    fi

    -ext-log registering callback for function hook $hook_name as $callback_function
}

# adds an autocompletion to antigen command
#
# usage:
#   -ext-compadd "extension-command"
function -ext-compadd () {
    local compadd_function="compadd-ext-$1"
    eval "function $compadd_function () {
        compadd "$1"
    }"
    -ext-hook "_antigen" $compadd_function
}

# loads a given extension (ie, sources it)
#
# usage:
#   antigen ext "extname"
#
# it the extension is not found it logs the error and moves along
function antigen-ext () {
    local extension_name="$1"
    local extension_path="$ADOTDIR/ext/$1.zsh"
    -ext-log loading extension "$extension_name" from $extension_path
    if [ -e "$extension_path" ]; then
        source "$extension_path"
    else
        -ext-log-error "No extension found!: $extension_name ($extension_path)"
    fi
}
