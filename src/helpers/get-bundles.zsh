# Returns bundle names from _ANTIGEN_BUNDLE_RECORD
#
# Usage
#   -antigen-get-bundles
#
# Returns
#   List of bundles installed
-antigen-get-bundles () {
  local bundles
  local mode
  local revision

  mode="short"
  if [[ $1 == "--long" ]]; then
    mode="long"
  fi

  bundles=$(-antigen-echo-record | sort -u | cut -d' ' -f1)
  # echo $bundles: Quick hack to split list
  for bundle in $(echo $bundles); do
    revision=$(-antigen-bundle-rev $bundle)
    if [[ $mode == "short" ]] then
      echo "$(-antigen-bundle-short-name $bundle) @ $revision"
    else
      echo "$(-antigen-find-record $bundle) @ $revision"
    fi
  done
}

