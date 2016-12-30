# Returns bundle names from _ANTIGEN_BUNDLE_RECORD
#
# Usage
#   -antigen-get-bundles
#
# Returns
#   List of bundles installed
-antigen-get-bundles () {
  local bundles

  bundles=$(-antigen-echo-record | sort -u | cut -d' ' -f1)
  for bundle in $bundles; do
    echo "$(-antigen-bundle-short-name $bundle)"
  done
}

