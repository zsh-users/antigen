antigen-list () {
    # List all currently installed bundles.
    if [[ -z "$_ANTIGEN_BUNDLE_RECORD" ]]; then
        echo "You don't have any bundles." >&2
        return 1
    else
        -antigen-echo-record | sort -u
    fi
}
