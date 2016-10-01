antigen-snapshot () {

    local snapshot_file="${1:-antigen-shapshot}"

    # The snapshot content lines are pairs of repo-url and git version hash, in
    # the form:
    #   <version-hash> <repo-url>
    local snapshot_content="$(
        -antigen-echo-record |
        awk '$4 == "true" {print $1}' |
        sort -u |
        while read url; do
            local dir="$(-antigen-get-clone-dir "$url")"
            local version_hash="$(cd "$dir" && git rev-parse HEAD)"
            echo "$version_hash $url"
        done)"

    {
        # The first line in the snapshot file is for metadata, in the form:
        #   key='value'; key='value'; key='value';
        # Where `key`s are valid shell variable names.

        # Snapshot version. Has no relation to antigen version. If the snapshot
        # file format changes, this number can be incremented.
        echo -n "version='1';"

        # Snapshot creation date+time.
        echo -n " created_on='$(date)';"

        # Add a checksum with the md5 checksum of all the snapshot lines.
        chksum() { (md5sum; test $? = 127 && md5) 2>/dev/null | cut -d' ' -f1 }
        local checksum="$(echo "$snapshot_content" | chksum)"
        unset -f chksum;
        echo -n " checksum='${checksum%% *}';"

        # A newline after the metadata and then the snapshot lines.
        echo "\n$snapshot_content"

    } > "$snapshot_file"

}
