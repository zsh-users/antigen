Load the plugin with no local clone.

  $ antigen-bundle $PLUGIN_DIR --no-local-clone

Check if the plugin is loaded correctly.

  $ hehe
  hehe

Confirm no clone is made.

  $ test -d "$ADOTDIR/repos"
  [1]

Load the plugin with a clone.

  $ antigen-bundle $PLUGIN_DIR &> /dev/null

Empty the record.

  $ _ANTIGEN_BUNDLE_RECORD=

Load the plugin again with no local clone.

  $ antigen-bundle $PLUGIN_DIR --no-local-clone

The cleanup should list the bundle's clone.

  $ antigen-cleanup --force
  You have clones for the following repos, but are not used.
    */test-plugin (glob)
  
  
  Deleting clone for */test-plugin... done. (glob)
