Firstly, no plugins, nothing to cleanup.

  $ antigen-cleanup --force
  You don't have any bundles.

Load the plugins.

  $ antigen-bundle $PLUGIN_DIR &> /dev/null
  $ antigen-bundle $PLUGIN_DIR2 &> /dev/null

Check the listing.

  $ antigen-list
  .*/test-plugin @ master (re)
  .*/test-plugin2 @ master (re)

Nothing should be available for cleanup.

  $ antigen-cleanup --force
  You don't have any unidentified bundles.

Clear out the bundles record.

  $ _ANTIGEN_BUNDLE_RECORD=()

Check the listing, after clearing the record.

  $ antigen-list
  You don't have any bundles.
  [1]

Confirm the plugin directory exists.

  $ ls $_ANTIGEN_BUNDLES | wc -l
  1

Do the cleanup.

  $ antigen-cleanup --force
  You have clones for the following repos, but are not used.
  
  .*/test-plugin (re)
  .*/test-plugin2 (re)
  
  
  Deleting clone "*/test-plugin"... done. (glob)
  Deleting clone "*/test-plugin2"... done. (glob)

Check the listing, after cleanup.

  $ antigen-list
  You don't have any bundles.
  [1]

Confirm the plugin directory does not exist after cleanup.

  $ ls $_ANTIGEN_BUNDLES | wc -l
  0
