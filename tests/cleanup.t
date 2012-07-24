Load a plugin.

  $ antigen-bundle $PLUGIN_DIR
  Cloning into '*'... (glob)
  done.

Check the listing.

  $ antigen-list
  */test-plugin / plugin false (glob)

Clear out the bundles record.

  $ _ANTIGEN_BUNDLE_RECORD=""

Check the listing, after clearing the record.

  $ antigen-list
  You don't have any bundles.
  [1]

Confirm the plugin directory exists.

  $ ls dot-antigen/repos | wc -l
  1

Do the cleanup.

  $ antigen-cleanup --force
  You have clones for the following repos, but are not used.
    */test-plugin (glob)
  
  
  Deleting clone for */test-plugin... done. (glob)

Check the listing, after cleanup.

  $ antigen-list
  You don't have any bundles.
  [1]

Confirm the plugin directory does not exist after cleanup.

  $ ls dot-antigen/repos | wc -l
  0
