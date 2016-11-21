# Clears $0 and ${0} references from cached sources.
#
# This is needed otherwise plugins trying to source from a different path
# will break as those are now located at $_ZCACHE_PAYLOAD_PATH
#
# This does avoid function-context $0 references.
#
# This does handles the following patterns:
#   $0
#   ${0}
#   ${funcsourcetrace[1]%:*}
#   ${(%):-%N}
#   ${(%):-%x}
#
# Usage
#   -zcache-process-source "/path/to/source" ["theme"|"plugin"]
#
# Returns
#   Returns the cached sources without $0 and ${0} references
-zcache-process-source () {
    local src="$1"
    local btype="$2"

    # Removes $0 references globally (exclusively)
    local globals_only='/\{$/,/^\}/!{
                /\$.?0/i\'$'\n''__ZCACHE_FILE_PATH="'$src'"
                s/\$(.?)0(.?)/\$\1__ZCACHE_FILE_PATH\2/
    }'

    # Removes funcsourcetrace, and ${%} references globally
    local globals='/.*/{
        /\$.?(funcsourcetrace\[1\]\%\:\*|\(\%\)\:\-\%(N|x))/i\'$'\n''__ZCACHE_FILE_PATH="'$src'"
        s/\$(.?)(funcsourcetrace\[1\]\%\:\*|\(\%\)\:\-\%(N|x))(.?)/\$\1__ZCACHE_FILE_PATH\4/
    }'

    # Removes `local` from temes globally
    local sed_regexp_themes=''
    if [[ "$btype" == "theme" ]]; then
        themes='/\{$/,/^\}/!{
            s/^local //
        }'
        sed_regexp_themes="-e "$themes
    fi

	cat "$src" | sed -E -e $globals -e $globals_only $sed_regexp_themes
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
                _payload+=$(-zcache-process-source "$line" "$btype")
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

    echo -E $_payload | sed 's/\\NL/\'$'\n/g' >! "$_ZCACHE_PAYLOAD_PATH"
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
    elif [[ "$cmd" == "antigen-bundles" ]]; then
        grep '^[[:space:]]*[^[:space:]#]' | while read line; do
            _ZCACHE_BUNDLES+=("${(j: :)line//\#*/}")
        done
    elif [[ "$cmd" == "antigen-bundle" ]]; then
        shift 1
        _ZCACHE_BUNDLES+=("${(j: :)@}")
    elif [[ "$cmd" == "antigen-apply" ]]; then
        zcache-done
        antigen-apply
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
# Afected functions are antigen* (key ones are antigen, antigen-bundle,
# antigen-apply).
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

# Determines if cache is up-to-date with antigen configuration
#
# Usage
#   -zcache-cache-invalidated
#
# Returns
#   Either true or false depending if cache is up to date
-zcache-cache-invalidated () {
    [[ $_ANTIGEN_AUTODETECT_CONFIG_CHANGES == true && ! -f $_ZCACHE_BUNDLES_PATH || $(cat $_ZCACHE_BUNDLES_PATH) != "$_ZCACHE_BUNDLES" ]];
}
