-antigen-update-remote () {
  local clone_dir="$1"
  local url="$2"

  if [[ "$clone_dir" =~ "\/.zprezto" ]]; then
    if [[ "$(cd $clone_dir && git config --get remote.origin.url)" != "$url" ]]; then
      echo "Setting $(basename "$clone_dir") remote to $url"
      --plugin-git remote set-url origin $url
    fi
  fi
}

