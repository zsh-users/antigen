antigen-version () {
  local extensions

  printf "Antigen %s (%s)\nRevision date: %s\n" "{{ANTIGEN_VERSION}}" "{{ANTIGEN_REVISION}}" "{{ANTIGEN_REVISION_DATE}}"

  # Show extension information if any is available
  if (( $+functions[antigen-ext] )); then
    typeset -a extensions; extensions=($(antigen-ext-list))
    if [[ $#extensions -gt 0 ]]; then
      printf "Extensions loaded: %s\n" ${(j:, :)extensions}
    fi
  fi
}
