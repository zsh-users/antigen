# Returns bundle names from _ANTIGEN_BUNDLE_RECORD
#
# Usage
#   -antigen-get-bundles [--short|--simple|--long]
#
# Returns
#   List of bundles installed
-antigen-get-bundles () {
  local mode revision url bundle_name bundle_entry loc no_local_clone
  mode=${1:-"--short"}

  for record in $_ANTIGEN_BUNDLE_RECORD; do
    url="$(echo "$record" | cut -d' ' -f1)"
    bundle_name=$(-antigen-bundle-short-name $url)

    case "$mode" in
        --short)
          loc="$(echo "$record" | cut -d' ' -f2)"
          make_local_clone="$(echo "$record" | cut -d' ' -f4)"
          revision=$(-antigen-bundle-rev $url $make_local_clone)
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
