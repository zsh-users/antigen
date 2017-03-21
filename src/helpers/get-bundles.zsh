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

  for record in $_ANTIGEN_BUNDLE_RECORD; do
    url="$(echo "$record" | cut -d' ' -f1)"
    bundle_name=$(-antigen-bundle-short-name $url)

    case "$mode" in
        --short)
          revision=$(-antigen-bundle-rev $url)
          loc="$(echo "$record" | cut -d' ' -f2)"
          if [[ $loc != '/' ]]; then
            bundle_name="$bundle_name ~ $loc"
          fi
          echo "$bundle_name @ $revision"
        ;;
        --simple)
          echo "$bundle_name"
        ;;
        --long)
          echo "$record"
        ;;
     esac
  done
}
