# Returns the bundle's git revision
#
# Usage
#   -antigen-bundle-rev bundle-name [is_local_clone]
#
# Returns
#   Bundle rev-parse output (branch name or short ref name)
-antigen-bundle-rev () {
  local bundle=$1
  local is_local_clone=$2

  local bundle_path=$bundle
  # Get bunde path inside $ADOTDIR if bundle was effectively cloned
  if [[ "$is_local_clone" == "true" ]]; then
    bundle_path=$(-antigen-get-clone-dir $bundle)
  fi

  local ref
  ref=$(git --git-dir="$bundle_path/.git" rev-parse --abbrev-ref '@' 2>/dev/null)

  # Avoid 'HEAD' when in detached mode
  if [[ $ref == "HEAD" ]]; then
    ref=$(git --git-dir="$bundle_path/.git" describe --tags --exact-match 2>/dev/null \
	    || git --git-dir="$bundle_path/.git" rev-parse --short '@' 2>/dev/null || "-")
  fi
  echo $ref
}
