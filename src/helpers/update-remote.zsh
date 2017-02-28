-antigen-update-remote () {
  local url="$1"

  if [[ "$1" == "https://github.com/zsh-users/prezto.git" ]]; then
    if [[ "$(--plugin-git config --get remote.origin.url)" == "https://github.com/sorin-ionescu/prezto.git" ]]; then
      echo -n "Updating remote for prezto"
      --plugin-git remote set-url origin https://github.com/zsh-users/prezto.git
    fi
  fi
}

