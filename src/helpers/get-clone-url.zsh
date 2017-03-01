-antigen-get-clone-url () {
  # Takes a repo's clone dir and unmangles it, to give the repo's original url
  # that was used to create the given directory path.

  if [[ "$1" == ".zprezto" ]]; then
    echo "$(cd "$ADOTDIR/repos/.zprezto" && git config --get remote.origin.url)"
  else
    local _path="${1}"
    _path=${_path//^\$ADOTDIR\/repos\/}
    _path=${_path//-SLASH-/\/}
    _path=${_path//-COLON-/\:}
    url=${_path//-PIPE-/\|}
    echo "$url"
  fi
}

