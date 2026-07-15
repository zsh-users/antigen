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

  $ echo ${(j:\n:)_ANTIGEN_BUNDLE_RECORD} | grep theme | wc -l
  1

  $ echo ${(j:\n:)_ANTIGEN_BUNDLE_RECORD} | grep theme
  *silly.zsh-theme* (glob)

Load a second theme in the same session.

  $ antigen-theme $PLUGIN_DIR arrow &> /dev/null
  $ echo "$PS1"
  >

Second theme is listed as expected in antigen-list.

  $ antigen-list | wc -l
  1

  $ echo ${(j:\n:)_ANTIGEN_BUNDLE_RECORD} | grep theme
  *arrow* (glob)

Should be registered correctly in BUNDLE_RECORD.

  $ echo ${(j:\n:)_ANTIGEN_BUNDLE_RECORD} | grep theme | wc -l
  1

  $ echo ${(j:\n:)_ANTIGEN_BUNDLE_RECORD} | grep theme
  *arrow.zsh-theme* (glob)

Using the same theme does not re-install theme.

  $ antigen-theme $PLUGIN_DIR silly
  $ antigen-list --long
  *silly* (glob)

  $ antigen-theme $PLUGIN_DIR silly &> /dev/null
  [1]
  $ antigen-list --long | grep silly
  *silly* (glob)

Can load a theme without specifying a theme name:

  $ antigen-theme $PLUGIN_DIR
  $ antigen-list --long | grep test-plugin
  *test-plugin* (glob)

Do not change current directory.

  $ cd /tmp/ 
  $ antigen-theme $PLUGIN_DIR silly
  $ antigen-list --long | grep silly
  *silly* (glob)
  $ pwd
  /tmp

Do not provide a default theme name value.

  $ antigen-theme
  Antigen: Must provide a theme url or name.
  [1]

Warm about theme already active.

  $ antigen-theme $PLUGIN_DIR arrow
  $ antigen-list --long | grep arrow
  *arrow* (glob)
  $ antigen-theme $PLUGIN_DIR arrow
  Antigen: Theme "*" is already active. (glob)
  [1]
