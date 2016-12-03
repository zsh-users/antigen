Load the theme explicitly.

  $ antigen-theme $PLUGIN_DIR silly &> /dev/null
  $ echo "$PS1"
  prompt>

  $ antigen-theme $PLUGIN_DIR wrong
  Antigen: Failed to load theme.
  [1]
