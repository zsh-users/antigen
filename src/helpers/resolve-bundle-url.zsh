-antigen-resolve-bundle-url () {
    # Given an acceptable short/full form of a bundle's repo url, this function
    # echoes the full form of the repo's clone url.

    local url="$1"

    # Expand short github url syntax: `username/reponame`.
    if [[ $url != git://* &&
            $url != https://* &&
            $url != http://* &&
            $url != ssh://* &&
            $url != /* &&
            $url != git@github.com:*/*
            ]]; then
        url="https://github.com/${url%.git}.git"
    fi

    echo "$url"
}
