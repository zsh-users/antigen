antigen-bundles () {
  # Bulk add many bundles at one go. Empty lines and lines starting with a `#`
  # are ignored. Everything else is given to `antigen-bundle` as is, no
  # quoting rules applied.
  local line
  setopt localoptions no_extended_glob # See https://github.com/zsh-users/antigen/issues/456
  eval "$_ANTIGEN_GREP_COMMAND '^[[:space:]]*[^[:space:]#]'" | while read line; do
    antigen-bundle ${=line%#*}
  done
}
