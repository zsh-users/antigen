# Usage:
#   -antigen-bundle-short-name "https://github.com/user/repo.git[|*]" "[branch/name]"
# Returns:
#   user/repo@branch/name
-antigen-bundle-short-name () {
  local bundle_name="${1%|*}"
  local bundle_branch="$2"
  local match mbegin mend MATCH MBEGIN MEND

  [[ "$bundle_name" =~ '.*/(.*/.*).*$' ]] && bundle_name=$match[1]
  bundle_name="${bundle_name%.git*}"

  if [[ -n $bundle_branch ]]; then
    bundle_name="$bundle_name@$bundle_branch"
  fi

  echo $bundle_name
}
