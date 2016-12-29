# Loads a given theme.
#
# Shares the same syntax as antigen-bundle command.
#
# Usage
#   antigen-theme zsh/theme[.zsh-theme]
#
# Returns
#   0 if everything was succesfully
antigen-theme () {
  local record
  local result=0

  if [[ $_ANTIGEN_RESET_THEME_HOOKS == true ]]; then
      -antigen-theme-reset-hooks
  fi

  record=$(-antigen-find-record "theme")

  if [[ "$1" != */* && "$1" != --* ]]; then
    # The first argument is just a name of the plugin, to be picked up from
    # the default repo.
    local name="${1:-robbyrussell}"
    antigen-bundle --loc=themes/$name --btype=theme

  else
    antigen-bundle "$@" --btype=theme

  fi
  result=$?

  # Remove a theme from the record if the following conditions apply:
  #   - there was no error in bundling the given theme
  #   - there is a theme registered
  #   - registered theme is not the same as the current one
  if [[ $result == 0 && -n $record && ! $record =~ "$@" ]]; then
    # Remove entire line plus $\n character
    _ANTIGEN_BUNDLE_RECORD=${_ANTIGEN_BUNDLE_RECORD//$'\n'$record/}
  fi

  return $result
}

-antigen-theme-reset-hooks () {
  # This is only needed on interactive mode
  autoload -U add-zsh-hook is-at-least
  local hook

  # Clear out prompts
  PROMPT=""
  RPROMPT=""

  for hook in chpwd precmd preexec periodic; do
    # add-zsh-hook's -D option was introduced first in 4.3.6-dev and
    # 4.3.7 first stable, 4.3.5 and below may experiment minor issues
    # while switching themes interactively.
    if is-at-least 4.3.7; then
      add-zsh-hook -D "${hook}" "prompt_*"
      add-zsh-hook -D "${hook}" "*_${hook}" # common in omz themes 
    fi
    add-zsh-hook -d "${hook}" "vcs_info"  # common in omz themes
  done
}

