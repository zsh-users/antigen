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
  local name=$1 result=0 record
  local match mbegin mend MATCH MBEGIN MEND

  if [[ -z "$1" ]]; then
    printf "Antigen: Must provide a theme url or name.\n" >&2
    return 1
  fi

  -antigen-theme-reset-hooks

  record=$(-antigen-find-record "theme")
  if [[ "$1" != */* && "$1" != --* ]]; then
    # The first argument is just a name of the plugin, to be picked up from
    # the default repo.
    antigen-bundle --loc=themes/$name --btype=theme

  else
    antigen-bundle "$@" --btype=theme

  fi
  result=$?

  # Remove a theme from the record if the following conditions apply:
  #   - there was no error in bundling the given theme
  #   - there is a theme registered
  #   - registered theme is not the same as the current one
  if [[ $result == 0 && -n $record ]]; then
    # http://zsh-workers.zsh.narkive.com/QwfCWpW8/what-s-wrong-with-this-expression
    if [[ "$record" =~ "$@" ]]; then
      return $result
    else
      _ANTIGEN_BUNDLE_RECORD[$_ANTIGEN_BUNDLE_RECORD[(I)$record]]=()
    fi
  fi

  return $result
}

-antigen-theme-reset-hooks () {
  # This is only needed on interactive mode
  autoload -U add-zsh-hook is-at-least
  local hook

  # Clear out prompts
  PROMPT=""
  if [[ -n $RPROMPT ]]; then
    RPROMPT=""
  fi

  for hook in chpwd precmd preexec periodic; do
    add-zsh-hook -D "${hook}" "prompt_*"
    # common in omz themes
    add-zsh-hook -D "${hook}" "*_${hook}"
    add-zsh-hook -d "${hook}" "vcs_info"
  done
}
