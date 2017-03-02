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
  local bundle_name

  mode="short"
  if [[ $1 == "--long" ]]; then
    mode="long"
  elif [[ $1 == "--simple" ]]; then
    mode="simple"
  fi

  bundles=$(-antigen-echo-record | sort -u | cut -d' ' -f1)
  # echo $bundles: Quick hack to split list
  for bundle in $(echo $bundles); do
    if [[ $mode == "simple" ]]; then
      echo "$(-antigen-bundle-short-name $bundle)"
      continue
    fi
    revision=$(-antigen-bundle-rev $bundle)
    bundle_name=$(-antigen-bundle-short-name $bundle)
    if [[ $mode == "short" ]]; then
      echo "$bundle_name @ $revision"
    else
      echo "$(-antigen-find-record $bundle_name) @ $revision"
    fi
  done
}

