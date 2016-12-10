export _ZCACHE_PATH="${_ANTIGEN_CACHE_PATH:-$ADOTDIR/.cache}"
export _ZCACHE_PAYLOAD_PATH="$_ZCACHE_PATH/.zcache-payload"
export _ZCACHE_BUNDLES_PATH="$_ZCACHE_PATH/.zcache-bundles"
export _ZCACHE_EXTENSION_CLEAN_FUNCTIONS="${_ZCACHE_EXTENSION_CLEAN_FUNCTIONS:-true}"
export _ZCACHE_EXTENSION_ACTIVE=false
local -a _ZCACHE_BUNDLES

# Starts zcache execution.
#
# Hooks into various antigen commands to be able to record and cache multiple
# bundles, themes and plugins.
#
# Usage
#   zcache-start
#
# Returns
#   Nothing
zcache-start () {
    if [[ $_ZCACHE_EXTENSION_ACTIVE == true ]]; then
        return
    fi

    [[ ! -d "$_ZCACHE_PATH" ]] && mkdir -p "$_ZCACHE_PATH"
    -zcache-hook-antigen

    # Avoid running in interactive mode. This handles an specific case
    # where antigen is sourced from file (eval context) but antigen commands
    # are issued from toplevel (interactively).
    zle -N zle-line-init zcache-done
    _ZCACHE_EXTENSION_ACTIVE=true
}

# Generates (if needed) and loads cache.
#
# Unhooks antigen commands and removes various zcache functions.
#
# Usage
#   zcache-done
#
# Returns
#   Nothing
zcache-done () {
    if [[ -z $_ZCACHE_EXTENSION_ACTIVE ]]; then
        return 1
    fi
    unset _ZCACHE_EXTENSION_ACTIVE
    
    -zcache-unhook-antigen
    
    # Avoids seg fault on zsh 4.3.5
    if [[ ${#_ZCACHE_BUNDLES} -gt 0 ]]; then
        if ! zcache-cache-exists || -zcache-cache-invalidated; then
            -zcache-generate-cache
            -antigen-reset-compdump
        fi
        
        zcache-load-cache
    fi

    if [[ $_ZCACHE_EXTENSION_CLEAN_FUNCTIONS == true ]]; then
        unfunction -- ${(Mok)functions:#-zcache*}
    fi

    eval "function -zcache-$(functions -- antigen-update)"
    antigen-update () {
        -zcache-antigen-update "$@"
        antigen-reset
    }
    
    unset _ZCACHE_BUNDLES
}

# Returns true if cache is available.
#
# Usage
#   zcache-cache-exists
#
# Returns
#   Either 1 if cache exists or 0 if it does not exists
zcache-cache-exists () {
    [[ -f "$_ZCACHE_PAYLOAD_PATH" ]]
}

# Load bundles from cache (sourcing it)
#
# This function does not check if cache is available, do use zcache-cache-exists.
#
# Usage
#   zcache-load-cache
#
# Returns
#   Nothing
zcache-load-cache () {
    source "$_ZCACHE_PAYLOAD_PATH"
}

# Removes cache payload and metadata if available
#
# Usage
#   zcache-cache-reset
#
# Returns
#   Nothing
antigen-reset () {
    -zcache-remove-path () { [[ -f "$1" ]] && rm "$1" }
    -zcache-remove-path "$_ZCACHE_PAYLOAD_PATH"
    -zcache-remove-path "$_ZCACHE_BUNDLES_PATH"
    unfunction -- -zcache-remove-path
    echo 'Done. Please open a new shell to see the changes.'
}

# Deprecated for antigen-reset command
#
# Usage
#   zcache-cache-reset
#
# Returns
#   Nothing
antigen-cache-reset () {
    echo 'Deprecated in favor of antigen reset.'
    antigen-reset
}

# Antigen command to load antigen configuration
#
# This method is slighlty more performing than using various antigen-* methods.
#
# Usage
#   Referencing an antigen configuration file:
#
#       antigen-init "/path/to/antigenrc"
#
#   or using HEREDOCS:
#
#       antigen-init <<EOBUNDLES
#           antigen use oh-my-zsh
#
#           antigen bundle zsh/bundle
#           antigen bundle zsh/example
#
#           antigen theme zsh/theme
#
#           antigen apply
#       EOBUNDLES
#
# Returns
#   Nothing
antigen-init () {
    if zcache-cache-exists; then
        # Force cache to load - this does skip -zcache-cache-invalidate
        _ZCACHE_BUNDLES=$(cat $_ZCACHE_BUNDLES_PATH)
        zcache-done
        return
    fi

    local src="$1"
    if [[ -f "$src" ]]; then
        source "$src"
        return
    fi

    grep '^[[:space:]]*[^[:space:]#]' | while read line; do
        eval $line
    done
}

-antigen-interactive-mode # Updates _ANTIGEN_INTERACTIVE
# Refusing to run in interactive mode
if [[ $_ANTIGEN_CACHE_ENABLED == true ]]; then
    if [[ $_ANTIGEN_INTERACTIVE == false ]]; then
        zcache-start
    fi
else    
    # Disable antigen-init and antigen-reset commands if cache is disabled
    # and running in interactive modes
    unfunction -- antigen-init antigen-reset antigen-cache-reset
fi
