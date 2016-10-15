antigen-cleanup () {

    # Cleanup unused repositories.

    local force=false
    if [[ $1 == --force ]]; then
        force=true
    fi

    if [[ ! -d "$ADOTDIR/repos" || -z "$(\ls "$ADOTDIR/repos/")" ]]; then
        echo "You don't have any bundles."
        return 0
    fi

    # Find directores in ADOTDIR/repos, that are not in the bundles record.
    local unused_clones="$(comm -13 \
        <(-antigen-echo-record |
            awk '$4 == "true" {print $1}' |
            while read line; do
                -antigen-get-clone-dir "$line"
            done |
            sort -u) \
        <(\ls -d "$ADOTDIR/repos/"* | sort -u))"

    if [[ -z $unused_clones ]]; then
        echo "You don't have any unidentified bundles."
        return 0
    fi

    echo 'You have clones for the following repos, but are not used.'
    echo "$unused_clones" |
        while read line; do
            -antigen-get-clone-url "$line"
        done |
        sed -e 's/^/  /' -e 's/|/, branch /'

    if $force || (echo -n '\nDelete them all? [y/N] '; read -q); then
        echo
        echo
        echo "$unused_clones" | while read line; do
            echo -n "Deleting clone for $(-antigen-get-clone-url "$line")..."
            rm -rf "$line"
            echo ' done.'
        done
    else
        echo
        echo Nothing deleted.
    fi
}
