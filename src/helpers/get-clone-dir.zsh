-antigen-get-clone-dir () {
  # Takes a repo url and mangles it, giving the path that this url will be
  # cloned to. Doesn't actually clone anything.
  echo -n $ADOTDIR/repos/

  local url="${1}"
  url=${url//\//-SLASH-}
  url=${url//\:/-COLON-}
  path=${url//\|/-PIPE-}
  echo "$path"
}

