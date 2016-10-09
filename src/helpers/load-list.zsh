-antigen-load-list () {
    local url="$1"
    local loc="$2"
    local make_local_clone="$3"

    # The full location where the plugin is located.
    local location="$url/"
    if $make_local_clone; then
        location="$(-antigen-get-clone-dir "$url")/"
    fi

    if [[ $loc != "/" ]]; then
        location="$location$loc"
    fi

    if [[ ! -f "$location" && ! -d "$location" ]]; then
        return 1
    fi

    if [[ -f "$location" ]]; then
        echo "$location"
        return
    fi

    # If we have a `*.plugin.zsh`, source it.
    local script_plugin
    script_plugin=($location/*.plugin.zsh(N[1]))
    if [[ -f "$script_plugin" ]]; then
        echo "$script_plugin"
        return
    fi

    # Otherwise source init.
    if [[ -f $location/init.zsh ]]; then
        echo "$location/init.zsh"
        return
    fi

    # If there is no `*.plugin.zsh` file, source *all* the `*.zsh` files.
    local bundle_files
    bundle_files=($location/*.zsh(N) $location/*.sh(N))
    if [[ $#bundle_files -gt 0 ]]; then
        echo "${(j:\n:)bundle_files}"
        return
    fi
}
