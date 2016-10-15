# Syntaxes
#   antigen-bundle <url> [<loc>=/]
# Keyword only arguments:
#   branch - The branch of the repo to use for this bundle.
antigen-bundle () {
    # Bundle spec arguments' default values.
    local url="$ANTIGEN_DEFAULT_REPO_URL"
    local loc=/
    local branch=
    local no_local_clone=false
    local btype=plugin
    
    if [[ -z "$1" ]]; then
        echo "Must provide a bundle url or name."
        return 1
    fi

    eval "$(-antigen-parse-bundle "$@")"
    
    # Add it to the record.
    _ANTIGEN_BUNDLE_RECORD="$_ANTIGEN_BUNDLE_RECORD\n$url $loc $btype"
    _ANTIGEN_BUNDLE_RECORD="$_ANTIGEN_BUNDLE_RECORD $make_local_clone"

    # Ensure a clone exists for this repo, if needed.
    if $make_local_clone; then
        -antigen-ensure-repo "$url"
    fi

    # Load the plugin.
    -antigen-load "$url" "$loc" "$make_local_clone"

}
