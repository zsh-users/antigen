# Removes cache payload and metadata if available
#
# Usage
#   antigen-reset
#
# Returns
#   Nothing
antigen-reset () {
  [[ -f "$ANTIGEN_CACHE" ]] && rm -f "$ANTIGEN_CACHE" "$ANTIGEN_CACHE.zwc" 1> /dev/null
  [[ -f "$ANTIGEN_RSRC" ]] && rm -f "$ANTIGEN_RSRC" 1> /dev/null
  [[ -f "$ANTIGEN_COMPDUMP" ]] && rm -f "$ANTIGEN_COMPDUMP" "$ANTIGEN_COMPDUMP.zwc" 1> /dev/null
  [[ -f "$ANTIGEN_LOCK" ]] && rm -f "$ANTIGEN_LOCK" 1> /dev/null
  echo 'Done. Please open a new shell to see the changes.'
}
