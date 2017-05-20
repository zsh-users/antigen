antigen-version () {
  local revision=""
  if [[ -d $_ANTIGEN_INSTALL_DIR/.git ]]; then
    revision=" ($(git --git-dir=$_ANTIGEN_INSTALL_DIR/.git rev-parse --short '@'))"
  fi

  echo "Antigen {{ANTIGEN_VERSION}}$revision"
}

