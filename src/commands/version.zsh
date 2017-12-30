antigen-version () {
  local extensions revision=""
  if [[ -d $_ANTIGEN_INSTALL_DIR/.git ]]; then
    revision=" ($(git --git-dir=$_ANTIGEN_INSTALL_DIR/.git rev-parse --short '@'))"
  fi

  printf "Antigen %s%s\nBuilt: %s\n" "{{ANTIGEN_VERSION}}" $revision "{{ANTIGEN_BUILD_DATE}}"
  if (( $+functions[antigen-ext] )); then
    typeset -a extensions; extensions=($(antigen-ext-list))
    if [[ $#extensions -gt 0 ]]; then
      printf "Extensions loaded: %s\n" ${(j:, :)extensions}
    fi
  fi
}
