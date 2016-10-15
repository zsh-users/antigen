-antigen-get-clone-dir () {
    # Takes a repo url and gives out the path that this url needs to be cloned
    # to. Doesn't actually clone anything.
    echo -n $ADOTDIR/repos/

    if [[ "$1" == "https://github.com/sorin-ionescu/prezto.git" ]]; then
        # Prezto's directory *has* to be `.zprezto`.
        echo .zprezto
    else
        local url="${1}"
        url=${url//\//-SLASH-}
        url=${url//\:/-COLON-}
        path=${url//\|/-PIPE-}
        echo "$path"
    fi
}
