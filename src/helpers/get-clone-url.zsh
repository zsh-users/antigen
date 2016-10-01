-antigen-get-clone-url () {
    # Takes a repo's clone dir and gives out the repo's original url that was
    # used to create the given directory path.

    if [[ "$1" == ".zprezto" ]]; then
        # Prezto's (in `.zprezto`), is assumed to be from `sorin-ionescu`'s
        # remote.
        echo https://github.com/sorin-ionescu/prezto.git

    else
        echo "$1" | sed \
            -e "s:^$ADOTDIR/repos/::" \
            -e 's.-SLASH-./.g' \
            -e 's.-COLON-.:.g' \
            -e 's.-PIPE-.|.g'

    fi
}
