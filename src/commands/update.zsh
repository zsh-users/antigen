# Updates the bundles or a single bundle.
#
# Usage
#    antigen-update [example/bundle]
#
# Returns
#    Nothing. Performs a `git pull`.
antigen-update () {
    local bundle="$1"

    # Update your bundles, i.e., `git pull` in all the plugin repos.
    date >! $ADOTDIR/revert-info

    # Clear log
    :> $_ANTIGEN_LOG_PATH

    if [[ -n "$bundle" ]]; then
        local url=$(-antigen-resolve-bundle-url "$bundle")
        if [[ ! ${(MS)_ANTIGEN_BUNDLE_RECORD##$url} == "" ]]; then
            -antigen-update-bundle "$url"
        else
            echo "Bundle not found in record. Try 'antigen bundle $bundle' first."
            return 1
        fi
    else
        -antigen-echo-record |
            awk '$4 == "true" {print $1}' |
            sort -u | while read url; do
                -antigen-update-bundle $url
            done
    fi
}

# Updates a bundle performing a `git pull`.
#
# Usage
#    -antigen-update-bundle https://github.com/example/bundle.git
#
# Returns
#    Nothing. Performs a `git pull`.
-antigen-update-bundle () {
    local url="$1"

    if [[ ! -n "$url" ]]; then
        echo "Antigen: Missing argument."
        return 1
    fi

    local clone_dir="$(-antigen-get-clone-dir "$url")"
    if [[ -d "$clone_dir" ]]; then
        (echo -n "$clone_dir:"
            cd "$clone_dir"
            git rev-parse HEAD) >> $ADOTDIR/revert-info
    fi

    # update=true verbose=true
    -antigen-ensure-repo "$url" true true
}
