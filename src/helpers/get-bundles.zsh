# Returns bundle names from _ANTIGEN_BUNDLE_RECORD
#
# Usage
#   -antigen-get-bundles [--short|--simple|--long]
#
# Returns
#   List of bundles installed
-antigen-get-bundles () {
  local mode
  local revision
  local url
  local bundle_name
  local bundle_entry
  mode=${1:-"--short"}

  for record in ${(@f)_ANTIGEN_BUNDLE_RECORD}; do
    url="$(echo "$record" | cut -d' ' -f1)"
    bundle_name=$(-antigen-bundle-short-name $url)
    bundle_entry=$(-antigen-find-record $url)
    
    revision=$(-antigen-bundle-rev $url)
    
    case "$mode" in
        --short)
          echo "$bundle_name @ $revision"
        ;;
        --simple)
          echo "$bundle_name"
        ;;
        --long)
          echo "$record @ $revision"
        ;;
     esac
  done
}
