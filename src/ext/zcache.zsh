export _ZCACHE_PATH="${_ANTIGEN_CACHE_PATH:-$ADOTDIR/.cache}"
export _ZCACHE_PAYLOAD_PATH="$_ZCACHE_PATH/.zcache-payload"
export _ZCACHE_BUNDLES_PATH="$_ZCACHE_PATH/.zcache-bundles"
export _ZCACHE_EXTENSION_CLEAN_FUNCTIONS="${_ZCACHE_EXTENSION_CLEAN_FUNCTIONS:-true}"
export _ZCACHE_EXTENSION_ACTIVE=false
local -a _ZCACHE_BUNDLES

# Clears $0 and ${0} references from cached sources.
#
# This is needed otherwise plugins trying to source from a different path
# will break as those are now located at $_ZCACHE_PAYLOAD_PATH
#
# This does avoid function-context $0 references.
#
# Usage
#   -zcache-process-source "/path/to/source"
#
# Returns
#   Returns the cached sources without $0 and ${0} references
-zcache-process-source () {
    cat "$1" | sed -Ee '/\{$/,/^\}/!{
            /\$.?0/i\'$'\n''__ZCACHE_FILE_PATH="'$1'"
            s/\$(.?)0/\$\1__ZCACHE_FILE_PATH/
        }'
}

# Generates cache from listed bundles.
#
# Iterates over _ZCACHE_BUNDLES and install them (if needed) then join all needed
# sources into one, this is done through -antigen-load-list.
# Result is stored in _ZCACHE_PAYLOAD_PATH. Loaded bundles and metadata is stored
# in _ZCACHE_META_PATH.
#
# _ANTIGEN_BUNDLE_RECORD and fpath is stored in cache.
#
# Usage
#   -zcache-generate-cache
#   Uses _ZCACHE_BUNDLES (array)
#
# Returns
#   Nothing. Generates _ZCACHE_META_PATH and _ZCACHE_PAYLOAD_PATH
-zcache-generate-cache () {
    local -aU _extensions_paths
    local -a _bundles_meta
    local _payload=''
    local location

    _payload+="#-- START ZCACHE GENERATED FILE\NL"
    _payload+="#-- GENERATED: $(date)\NL"
    _payload+='#-- ANTIGEN {{ANTIGEN_VERSION}}\NL'
    for bundle in $_ZCACHE_BUNDLES; do
        # -antigen-load-list "$url" "$loc" "$make_local_clone"
        eval "$(-antigen-parse-bundle ${=bundle})"
        _bundles_meta+=("$url $loc $btype $make_local_clone $branch")

        if $make_local_clone; then
            -antigen-ensure-repo "$url"
        fi

        -antigen-load-list "$url" "$loc" "$make_local_clone" | while read line; do
            if [[ -f "$line" ]]; then
                _payload+="#-- SOURCE: $line\NL"
                _payload+=$(-zcache-process-source "$line")
                _payload+="\NL;#-- END SOURCE\NL"
            fi
        done

        if $make_local_clone; then
            location="$(-antigen-get-clone-dir "$url")/$loc"
        else
            location="$url/"
        fi

        if [[ -d "$location" ]]; then
            _extensions_paths+=($location)
        fi
    done

    _payload+="fpath+=(${_extensions_paths[@]})\NL"
    _payload+="unset __ZCACHE_FILE_PATH\NL"
    # \NL (\n) prefix is for backward compatibility
    _payload+="export _ANTIGEN_BUNDLE_RECORD=\"\NL${(j:\NL:)_bundles_meta}\"\NL"
    _payload+="export _ZCACHE_CACHE_LOADED=true\NL"
    _payload+="export _ZCACHE_CACHE_VERSION={{ANTIGEN_VERSION}}\NL"
    _payload+="#-- END ZCACHE GENERATED FILE\NL"

    echo -E $_payload | sed 's/\\NL/\'$'\n/g' >>! "$_ZCACHE_PAYLOAD_PATH"
    echo "$_ZCACHE_BUNDLES" >! "$_ZCACHE_BUNDLES_PATH"
}

# Generic hook function for various antigen-* commands.
#
# The function is used to defer the bundling performed by commands such as
# bundle, theme and init. This way we can record all the bundled plugins and
# install/source/cache in one single step.
#
# Usage
#   -zcache-antigen-hook <arguments>
#
# Returns
#   Nothing. Updates _ZACHE_BUNDLES array.
-zcache-antigen-hook () {
    local cmd="$1"
    local subcommand="$2"

    if [[ "$cmd" == "antigen" ]]; then
        if [[ ! -z "$subcommand" ]]; then
            shift 2
        fi
        -zcache-antigen $subcommand $@
    elif [[ "$cmd" == "antigen-bundle" ]]; then
        shift 1
        _ZCACHE_BUNDLES+=("${(j: :)@}")
    elif [[ "$cmd" == "antigen-apply" ]]; then
        zcache-done
    else
        shift 1
        -zcache-$cmd $@
    fi
}

# Unhook antigen functions to be able to call antigen commands normally.
#
# After generating and loading of cache there is no need for defered command
# calls, so we are leaving antigen as it was before zcache was loaded.
#
# Afected functions are antigen, antigen-bundle and antigen-apply.
#
# See -zcache-hook-antigen
#
# Usage
#   -zcache-unhook-antigen
#
# Returns
#   Nothing
-zcache-unhook-antigen () {
    for function in ${(Mok)functions:#antigen*}; do
        eval "function $(functions -- -zcache-$function | sed 's/-zcache-//')"
    done
}

# Hooks various antigen functions to be able to defer command execution.
#
# To be able to record and cache multiple bundles when antigen runs we are
# hooking into multiple antigen commands, either deferring it's execution
# or dropping it.
#
# Afected functions are antigen, antigen-bundle and antigen-apply.
#
# See -zcache-unhook-antigen
#
# Usage
#   -zcache-hook-antigen
#
# Returns
#   Nothing
-zcache-hook-antigen () {
    for function in ${(Mok)functions:#antigen*}; do
        eval "function -zcache-$(functions -- $function)"
        $function () { -zcache-antigen-hook $0 "$@" }
    done
}

# Updates _ANTIGEN_INTERACTIVE environment variable to reflect
# if antigen is running in an interactive shell or from sourcing.
#
# This function check ZSH_EVAL_CONTEXT if available or functrace otherwise.
# If _ANTIGEN_INTERACTIVE is set to true it won't re-check again.
#
# Usage
#   -zcache-interactive-mode
#
# Returns
#   Either true or false depending if we are running in interactive mode
-zcache-interactive-mode () {
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

# Determines if cache is up-to-date with antigen configuration
#
# Usage
#   -zcache-cache-invalidated
#
# Returns
#   Either true or false depending if cache is up to date
-zcache-cache-invalidated () {
    [[ $_ANTIGEN_AUTODETECT_CONFIG_CHANGES == true && $(cat $_ZCACHE_BUNDLES_PATH) != "$_ZCACHE_BUNDLES" ]];
}

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
        fi
        
        zcache-load-cache
    fi
    
    if [[ $_ZCACHE_EXTENSION_CLEAN_FUNCTIONS == true ]]; then
        unfunction -- ${(Mok)functions:#-zcache*}
    fi

    eval "function -zcache-$(functions -- antigen-update)"
    antigen-update () {
        -zcache-antigen-update "$@"
        antigen-cache-reset
    }
    
    zle -D zle-line-init
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
antigen-cache-reset () {
    -zcache-remove-path () { [[ -f "$1" ]] && rm "$1" }
    -zcache-remove-path "$_ZCACHE_PAYLOAD_PATH"
    -zcache-remove-path "$_ZCACHE_BUNDLES_PATH"
    unfunction -- -zcache-remove-path
    echo 'Done. Please open a new shell to see the changes.'
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

-zcache-interactive-mode # Updates _ANTIGEN_INTERACTIVE
# Refusing to run in interactive mode
if [[ $_ANTIGEN_CACHE_ENABLED == true && $_ANTIGEN_INTERACTIVE == false ]]; then
    zcache-start
fi
