antigen-update () {
    # Update your bundles, i.e., `git pull` in all the plugin repos.
    date >! $ADOTDIR/revert-info

    # Clear log
    :> $_ANTIGEN_LOG_PATH

    -antigen-echo-record |
        awk '$4 == "true" {print $1}' |
        sort -u |
        while read url; do
            local clone_dir="$(-antigen-get-clone-dir "$url")"
            if [[ -d "$clone_dir" ]]; then
                (echo -n "$clone_dir:"
                    cd "$clone_dir"
                    git rev-parse HEAD) >> $ADOTDIR/revert-info
            fi

            # update=true verbose=true
            -antigen-ensure-repo "$url" true true
        done
}
