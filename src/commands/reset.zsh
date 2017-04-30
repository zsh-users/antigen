# Removes cache payload and metadata if available
#
# Usage
#   antigen-reset
#
# Returns
#   Nothing
antigen-reset () {
  [[ -f "$ANTIGEN_CACHE" ]] && rm -f "$ANTIGEN_CACHE"
  [[ -f "$ANTIGEN_RSRC" ]] && rm -f "$ANTIGEN_RSRC"
  [[ -f "$ANTIGEN_COMPDUMP" ]] && rm -f "$ANTIGEN_COMPDUMP"
  echo 'Done. Please open a new shell to see the changes.'
}
