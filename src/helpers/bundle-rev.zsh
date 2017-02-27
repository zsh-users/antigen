# Returns the bundle's git revision
#
# Usage
#   -antigen-bundle-rev bundle-name
#
# Returns
#   Bundle rev-parse output
-antigen-bundle-rev () {
  local bundle=$1
  local bundle_path=$(-antigen-get-clone-dir $bundle)
  local ref
  ref=$(git --git-dir="$bundle_path/.git" rev-parse --abbrev-ref '@')

  # Avoid 'HEAD" when in detached mode
  if [[ $ref == "HEAD" ]]; then
    ref=$(git --git-dir="$bundle_path/.git" rev-parse '@')
  fi
  echo $ref
}
