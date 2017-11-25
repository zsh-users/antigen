antigen-use () {
  if [[ $1 == oh-my-zsh ]]; then
    -antigen-use-oh-my-zsh
  elif [[ $1 == prezto ]]; then
    -antigen-use-prezto
  elif [[ $1 != "" ]]; then
    ANTIGEN_DEFAULT_REPO_URL=$1
    antigen-bundle $@
  else
    echo 'Usage: antigen-use <library-name|url>' >&2
    echo 'Where <library-name> is any one of the following:' >&2
    echo ' * oh-my-zsh' >&2
    echo ' * prezto' >&2
    echo '<url> is the full url.' >&2
    return 1
  fi
}
