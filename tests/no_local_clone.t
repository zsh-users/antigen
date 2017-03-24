Load the plugin with no local clone.

  $ antigen-bundle $PLUGIN_DIR --no-local-clone

Check if the plugin is loaded correctly.

  $ hehe
  hehe

Confirm no clone is made.

  $ ls $_ANTIGEN_BUNDLES

Load the plugin with a clone.

  $ antigen-bundle $PLUGIN_DIR &> /dev/null
  $ ls $_ANTIGEN_BUNDLES
  no_local_clone.t

Empty the record.

  $ _ANTIGEN_BUNDLE_RECORD=()
  $ antigen list
  You don't have any bundles.
  [1]

Load the plugin again with no local clone.

  $ antigen-bundle $PLUGIN_DIR --no-local-clone
  $ antigen list
  no_local_clone.t/test-plugin @ master
  $ ls $_ANTIGEN_BUNDLES
  no_local_clone.t

The cleanup should list the bundle's clone.

  $ _ANTIGEN_BUNDLE_RECORD=()
  $ antigen-cache-gen
  $ antigen-cleanup --force
  You have clones for the following repos, but are not used.
  
  .*/test-plugin (re)
  
  
  Deleting clone ".*/test-plugin"... done. (re)

  $ ls $_ANTIGEN_BUNDLES
