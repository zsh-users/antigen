-antigen-get-clone-dir () {
  # Takes a repo url and mangles it, giving the path that this url will be
  # cloned to. Doesn't actually clone anything.
  echo -n $_ANTIGEN_BUNDLES/

  if [[ "$1" == "$ANTIGEN_PREZTO_REPO_URL" ]]; then
    # Prezto's directory *has* to be `.zprezto`.
    echo .zprezto
  else
    local url=$(-antigen-bundle-short-name "$1")
    url=${url//\|/-}
    url=${url//\*/x}
    echo $url
  fi
}

