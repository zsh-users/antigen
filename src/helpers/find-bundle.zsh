# Filters _ANTIGEN_BUNDLE_RECORD for $1
#
# Usage
#   -antigen-find-bundle example/bundle
#
# Returns
#   String if bundle is found
-antigen-find-bundle () {
  echo $(-antigen-find-record $1 | cut -d' ' -f1)
}

