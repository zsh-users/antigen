# Returns bundles flagged as make_local_clone
#
# Usage
#    -antigen-cloned-bundles
#
# Returns
#    Bundle metadata
-antigen-get-cloned-bundles() {
  -antigen-echo-record |
      awk '$4 == "true" {print $1}' |
      sort -u
}
