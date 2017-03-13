-antigen-use-oh-my-zsh () {
  if [[ -z "$ZSH" ]]; then
    ZSH="$(-antigen-get-clone-dir "$ANTIGEN_DEFAULT_REPO_URL")"
  fi
  if [[ -z "$ZSH_CACHE_DIR" ]]; then
    ZSH_CACHE_DIR="$ZSH/cache/"
  fi
  antigen-bundle --loc=lib
}

