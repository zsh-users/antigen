# Returns the bundle's git revision
#
# Usage
#   -antigen-bundle-rev bundle-name
#
# Returns
#   Bundle rev-parse output (branch name or short ref name)
-antigen-bundle-rev () {
  local bundle=$1
  local bundle_path=$(-antigen-get-clone-dir $bundle)
  local ref
  ref=$(git --git-dir="$bundle_path/.git" rev-parse --abbrev-ref '@')

  # Avoid 'HEAD' when in detached mode
  if [[ $ref == "HEAD" ]]; then
    ref=$(git --git-dir="$bundle_path/.git" describe --tags --exact-match 2>/dev/null || git --git-dir="$bundle_path/.git" rev-parse --short '@')
  fi
  echo $ref
}
