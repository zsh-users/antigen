-antigen-update-remote () {
  local clone_dir="$1"
  local url="$2"

  if [[ "$url" == "https://github.com/zsh-users/prezto.git" ]]; then
    if [[ "$(cd $clone_dir && git config --get remote.origin.url)" == "https://github.com/sorin-ionescu/prezto.git" ]]; then
      echo "Upgrading from sorin-ionescu/prezto to zsh-users/prezto"
      --plugin-git remote set-url origin $url
    fi
  fi
}

