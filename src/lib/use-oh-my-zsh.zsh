-antigen-use-oh-my-zsh () {
  typeset -g ZSH ZSH_CACHE_DIR
  ANTIGEN_DEFAULT_REPO_URL=$ANTIGEN_OMZ_REPO_URL
  if [[ -z "$ZSH" ]]; then
    ZSH="$(-antigen-get-clone-dir "$ANTIGEN_DEFAULT_REPO_URL")"
  fi
  if [[ -z "$ZSH_CACHE_DIR" ]]; then
    ZSH_CACHE_DIR="$ZSH/cache/"
  fi
  antigen-bundle --loc=lib
}
