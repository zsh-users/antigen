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

   # Ensure a clone exists for this repo, if needed.
    if $make_local_clone; then
        if ! -antigen-ensure-repo "$url"; then
            # Return immediately if there is an error cloning
            return 1
        fi
    fi

    # Load the plugin.
    -antigen-load "$url" "$loc" "$make_local_clone" "$btype"

    # Add it to the record.
    local bundle_record="$url $loc $btype $make_local_clone"
    if [[ ! $_ANTIGEN_BUNDLE_RECORD =~ "$bundle_record" ]]; then
        # TODO Use array instead of string
        _ANTIGEN_BUNDLE_RECORD="$_ANTIGEN_BUNDLE_RECORD\n$bundle_record"
    fi
}
