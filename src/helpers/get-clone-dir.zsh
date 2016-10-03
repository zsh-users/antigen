-antigen-get-clone-dir () {
    # Takes a repo url and gives out the path that this url needs to be cloned
    # to. Doesn't actually clone anything.
    echo -n $ADOTDIR/repos/

    if [[ "$1" == "https://github.com/sorin-ionescu/prezto.git" ]]; then
        # Prezto's directory *has* to be `.zprezto`.
        echo .zprezto

    else
        echo "$1" | sed \
            -e 's./.-SLASH-.g' \
            -e 's.:.-COLON-.g' \
            -e 's.|.-PIPE-.g'

    fi
}
