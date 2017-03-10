-antigen-bundle-short-name () {
  local bundle_name=$(echo "$1" | sed -E "s|.*/(.*/.*).*|\1|"|sed -E "s|\.git.*$||g")
  local bundle_branch=$2
    
  if [[ "$bundle_branch" == "" ]]; then
    echo $bundle_name
    return
  fi

  echo "$bundle_name@$bundle_branch"
}

