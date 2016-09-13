export _ZCACHE_PATH="${_ANTIGEN_CACHE_PATH:-$_ANTIGEN_INSTALL_DIR/.cache}"
export _ZCACHE_PAYLOAD_PATH="$_ZCACHE_PATH/.zcache-payload"
export _ZCACHE_META_PATH="$_ZCACHE_PATH/.zcache-meta"
export _ZCACHE_EXTENSION_LOADED=true
local -a _ZCACHE_BUNDLES

# Clears $0 and ${0} references from cached sources.
#
# This is needed otherwise plugins trying to source from a different path
# will break as those are now located at $_ZCACHE_PAYLOAD_PATH
#
# Usage
#   -zcache-process-source "/path/to/source"
#
# Returns
#   Returns the cached sources without $0 and ${0} references
-zcache-process-source () {
    cat "$1" \
        | sed $'/\${0/i\\\n__ZCACHE_FILE_PATH=\''$1$'\'\n' \
        | sed -e "s/\${0/\${__ZCACHE_FILE_PATH/" \
        | sed $'/\$0/i\\\n__ZCACHE_FILE_PATH=\''$1$'\'\n' \
        | sed -e "s/\$0/\$__ZCACHE_FILE_PATH/"
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
    local -a _extensions_paths
    local -a _bundles_meta
    local _payload=''
    local location

    _payload+="#-- START ZCACHE GENERATED FILE\NL"
    _payload+="#-- GENERATED: $(date)\NL"
    for bundle in $_ZCACHE_BUNDLES; do
        # -antigen-load-list "$url" "$loc" "$make_local_clone"
        eval "$(-antigen-parse-bundle ${=bundle})"
        _bundles_meta+=("$url $loc $btype $make_local_clone $branch")
        # url=$(-antigen-get-clone-dir "$url")
        -antigen-load-list "$url" "$loc" "$make_local_clone" | while read line; do
            if [[ -f "$line" ]]; then
                _payload+="#-- SOURCE: $line\NL"
                _payload+=$(-zcache-process-source "$line")
                _payload+="\NL;#-- END SOURCE\NL"
            elif [[ -d "$line" ]]; then
                _extensions_paths+=("$line")
            fi
        done

        if $make_local_clone; then
            location="$(-antigen-get-clone-dir "$url")/$loc"
        else
            location="$url/"
        fi
        # Add to $fpath, for completion(s), if not in there already
        if (( ! ${_extensions_paths[(I)$location]} )); then
            _extensions_paths+=($location)
        fi
    done

    _payload+="fpath+=(${(j: :)_extensions_paths});\NL"
    _payload+="unset __ZCACHE_FILE_PATH\NL"
    # \NL (\n) prefix is for backward compatibility
    _payload+="export _ANTIGEN_BUNDLE_RECORD=\"\NL${(j:\NL:)_bundles_meta}\"\NL"
    _payload+="export _ZCACHE_CACHE_LOADED=true\NL"
    _payload+="#-- END ZCACHE GENERATED FILE\NL"

    /bin/echo -E $_payload | sed 's/\\NL/\'$'\n/g' >>! $_ZCACHE_PAYLOAD_PATH
    echo "${(j:\n:)_bundles_meta}" >>! $_ZCACHE_META_PATH
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

    case "$cmd" in
        use)
            antigen-use "$2"
            ;;
        init)
            antigen-init "$2"
            ;;
        theme)
            antigen-theme "$2" "$3" "$4"
            ;;
        bundle)
            antigen-bundle "$2" "$3" "$4"
            ;;
        apply)
            zcache-done
            ;;
        *)
            if functions "antigen-$cmd" > /dev/null; then
                "antigen-$cmd" "$@"
            else
                # TODO Remove on 2.x
                ! zcache-cache-exists && -zcache-antigen-bundle "${=@}"
                _ZCACHE_BUNDLES+=("$*")
            fi
        ;;
    esac
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
    for function in antigen antigen-bundle antigen-apply; do
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
    for function in antigen antigen-bundle antigen-apply; do
        eval "function -zcache-$(functions -- $function)"
        $function () { -zcache-antigen-hook "$@" }
    done

    eval "function -zcache-$(functions -- antigen-update)"
    antigen-update () {
        -zcache-antigen-update "$@"
        antigen-cache-reset
    }
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
    [[ ! -d "$_ZCACHE_PATH" ]] && mkdir -p "$_ZCACHE_PATH"
    -zcache-hook-antigen
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
    -zcache-unhook-antigen

    ! zcache-cache-exists && -zcache-generate-cache
    zcache-load-cache

    unfunction -- -zcache-generate-cache -zcache-antigen-hook -zcache-unhook-antigen \
    -zcache-hook-antigen zcache-start zcache-done -zcache-antigen -zcache-antigen-apply \
    -zcache-antigen-bundle -zcache-process-source

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
    [[ -f "$_ZCACHE_META_PATH" ]] && rm "$_ZCACHE_META_PATH"
    [[ -f "$_ZCACHE_PAYLOAD_PATH" ]] && rm "$_ZCACHE_PAYLOAD_PATH"
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
