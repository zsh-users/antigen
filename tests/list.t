Empty initial listing.

  $ antigen-list
  You don't have any bundles.
  [1]

Add a bundle.

  $ antigen-bundle $PLUGIN_DIR &> /dev/null
  $ antigen-list
  */test-plugin / plugin true (glob)

Add same bundle and check uniqueness.

  $ antigen-bundle $PLUGIN_DIR
  $ antigen-list
  */test-plugin / plugin true (glob)

Add another bundle.

  $ antigen-bundle $PLUGIN_DIR2 &> /dev/null
  $ antigen-list
  */test-plugin / plugin true (glob)
  */test-plugin2 / plugin true (glob)
