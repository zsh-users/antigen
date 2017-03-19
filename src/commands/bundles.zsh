antigen-bundles () {
  # Bulk add many bundles at one go. Empty lines and lines starting with a `#`
  # are ignored. Everything else is given to `antigen-bundle` as is, no
  # quoting rules applied.
  local line
  grep '^[[:space:]]*[^[:space:]#]' | while read line; do
    antigen-bundle ${=line}
  done
}
