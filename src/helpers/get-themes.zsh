# Returns a list of themes from a default library (omz)
#
# Usage
#   -antigen-get-themes
#
# Returns
#   List of themes by name
-antigen-get-themes () {
  local library='ohmyzsh/ohmyzsh'
  local bundle=$(-antigen-find-bundle $library)

  if [[ -n "$bundle" ]]; then
    local dir=$(-antigen-get-clone-dir $ANTIGEN_DEFAULT_REPO_URL)
    echo $(ls $dir/themes/ | eval "$_ANTIGEN_GREP_COMMAND '.zsh-theme$'" | sed 's/.zsh-theme//')
  fi

  return 0
}

