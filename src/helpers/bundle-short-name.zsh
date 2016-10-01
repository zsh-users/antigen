-antigen-bundle-short-name () {
    echo "$@" | sed -E "s|.*/(.*/.*).git.*$|\1|"
}
