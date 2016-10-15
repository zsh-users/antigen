-antigen-get-clone-url () {
    # Takes a repo's clone dir and gives out the repo's original url that was
    # used to create the given directory path.

    if [[ "$1" == ".zprezto" ]]; then
        # Prezto's (in `.zprezto`), is assumed to be from `sorin-ionescu`'s
        # remote.
        echo https://github.com/sorin-ionescu/prezto.git
    else
        local _path="${1}"
        _path=${_path//^\$ADOTDIR\/repos\/}
        _path=${_path//-SLASH-/\/}
        _path=${_path//-COLON-/\:}
        url=${_path//-PIPE-/\|}
        echo "$url"
    fi
}
