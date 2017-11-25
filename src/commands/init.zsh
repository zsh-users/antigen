# Antigen command to load antigen configuration
#
# This method is slighlty more performing than using various antigen-* methods.
#
# Usage
#   Referencing an antigen configuration file:
#
#       antigen-init "/path/to/antigenrc"
#
#   or using HEREDOCS:
#
#       antigen-init <<EOBUNDLES
#           antigen use oh-my-zsh
#
#           antigen bundle zsh/bundle
#           antigen bundle zsh/example
#
#           antigen theme zsh/theme
#
#           antigen apply
#       EOBUNDLES
#
# Returns
#   Nothing
antigen-init () {
  local src="$1" line

  # If we're given an argument it should be a path to a file
  if [[ -n "$src" ]]; then
    if [[ -f "$src" ]]; then
      source "$src"
      return
    else
      printf "Antigen: invalid argument provided.\n" >&2
      return 1
    fi
  fi

  # Otherwise we expect it to be a heredoc
  grep '^[[:space:]]*[^[:space:]#]' | while read -r line; do
    eval $line
  done
}
