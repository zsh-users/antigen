# Usage:
#  -antigen-get-clone-dir "https://github.com/zsh-users/zsh-syntax-highlighting.git[|feature/branch]"
# Returns:
#  $ANTIGEN_BUNDLES/zsh-users/zsh-syntax-highlighting[-feature-branch]
-antigen-get-clone-dir () {
  local bundle="$1"
  local url="${bundle%|*}"
  local branch
  [[ "$bundle" =~ "\|" ]] && branch="${bundle#*|}"

  # Takes a repo url and mangles it, giving the path that this url will be
  # cloned to. Doesn't actually clone anything.
  local clone_dir="$ANTIGEN_BUNDLES"

  if [[ "$bundle" == "$ANTIGEN_PREZTO_REPO_URL" ]]; then
    # Prezto's directory *has* to be `.zprezto`.
    clone_dir="$clone_dir/.zprezto"
  else
    url=$(-antigen-bundle-short-name $url)
    # Suffix with branch/tag name
    [[ -n "$branch" ]] && url="$url-${branch//\//-}"
    url=${url//\*/x}

    clone_dir="$clone_dir/$url"
  fi

  echo $clone_dir
}
