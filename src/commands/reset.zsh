# Removes cache payload and metadata if available
#
# Usage
#   antigen-reset
#
# Returns
#   Nothing
antigen-reset () {
  [[ -f "$_ANTIGEN_CACHE" ]] && rm -f "$_ANTIGEN_CACHE"
  echo 'Done. Please open a new shell to see the changes.'
}
