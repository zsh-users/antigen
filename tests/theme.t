Load the theme explicitly.

  $ antigen-theme $PLUGIN_DIR silly &> /dev/null
  $ echo "$PS1"
  prompt>

  $ antigen-theme $PLUGIN_DIR wrong
  Antigen: Failed to load theme.
  [1]

Theme should be listed correctly in antigen-list.

  $ antigen-list | wc -l
  1

Should be registered correctly in BUNDLE_RECORD.

  $ echo $_ANTIGEN_BUNDLE_RECORD | grep theme | wc -l
  1

  $ echo $_ANTIGEN_BUNDLE_RECORD | grep theme
  *silly.zsh-theme* (glob)

Load a second heme in the same session.

  $ antigen-theme $PLUGIN_DIR arrow &> /dev/null
  $ echo "$PS1"
  >

Second theme is listed as expected in antigen-list.

  $ antigen-list | wc -l
  1

  $ echo $_ANTIGEN_BUNDLE_RECORD | grep theme
  *arrow* (glob)

Should be registered correctly in BUNDLE_RECORD.

  $ echo $_ANTIGEN_BUNDLE_RECORD | grep theme | wc -l
  1

  $ echo $_ANTIGEN_BUNDLE_RECORD | grep theme
  *arrow.zsh-theme* (glob)

Using the same theme does not change anything.

  $ antigen-theme $PLUGIN_DIR arrow &> /dev/null
  $ antigen-list | grep arrow
  *arrow* (glob)

  $ antigen-theme $PLUGIN_DIR arrow &> /dev/null
  $ antigen-list | grep arrow
  *arrow* (glob)

Can load a theme without specifying a theme name:

  $ antigen-theme $PLUGIN_DIR
  $ antigen-list | grep arrow
  *arrow* (glob)

