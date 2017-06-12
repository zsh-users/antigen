antigen-version () {
  local version="{{ANTIGEN_VERSION}}"
  local extensions revision=""
  if [[ -d $_ANTIGEN_INSTALL_DIR/.git ]]; then
    revision=" ($(git --git-dir=$_ANTIGEN_INSTALL_DIR/.git rev-parse --short '@'))"
  fi

  printf "Antigen %s%s\n" $version $revision
  if (( $+functions[antigen-ext] )); then
    typeset -a extensions; extensions=($(antigen-ext-list))
    if [[ $#extensions > 0 ]]; then
      printf "Extensions loaded: %s\n" ${(j:, :)extensions}
    else
      printf "No extensions loaded.\n"
    fi
  fi
}
