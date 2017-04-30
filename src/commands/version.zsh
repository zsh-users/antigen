antigen-version () {
  local version="{{ANTIGEN_VERSION}}"
  local revision=""
  if [[ -d $_ANTIGEN_INSTALL_DIR/.git ]]; then
    revision=" ($(git --git-dir=$_ANTIGEN_INSTALL_DIR/.git rev-parse --short '@'))"
  fi

  printf "Antigen %s%s\n" $version $revision
}
