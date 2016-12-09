# Returns a list of themes from a default library (omz)
#
# Usage
#   -antigen-get-themes
#
# Returns
#   List of themes by name
-antigen-get-themes () {
  local library="robbyrussell/oh-my-zsh"
  local bundle=$(-antigen-find-bundle $library)

  if [[ -n "$bundle" ]]; then
    local url=$(-antigen-resolve-bundle-url $bundle)
    local dir=$(-antigen-get-clone-dir $url)
    echo $(ls $dir/themes | sed 's/.zsh-theme//')
  fi
  
  return 0
}
