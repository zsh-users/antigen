# Returns a list of themes from a default library (omz)
#
# Usage
#   -antigen-get-themes
#
# Returns
#   List of themes by name
-antigen-get-themes () {
  local library='robbyrussell/oh-my-zsh'
  local bundle=$(-antigen-find-bundle $library)

  if [[ -n "$bundle" ]]; then
    local dir=$(-antigen-get-clone-dir $ANTIGEN_DEFAULT_REPO_URL)
    echo $(ls $dir/themes/ | grep '.zsh-theme$' | sed 's/.zsh-theme//')
  fi

  return 0
}

