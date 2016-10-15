-antigen-bundle-short-name () {
    echo "$@" | sed -E "s|.*/(.*/.*)$|\1|"|sed -E "s|\.git$||g"
}
