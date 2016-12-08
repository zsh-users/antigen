# Returns bundle names from _ANTIGEN_BUNDLE_RECORD
#
# Usage
#   -antigen-get-bundles
#
# Returns
#   List f bundle installed
-antigen-get-bundles () {
  local bundles=$(echo $_ANTIGEN_BUNDLE_RECORD | cut -d' ' -f1)
  for bundle in $bundles; do
      echo $(-antigen-bundle-short-name $bundle)
  done
}
