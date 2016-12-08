Purge command removes a bundle from filesystem.
  $ antigen-bundle $PLUGIN_DIR &> /dev/null
  $ antigen-list | grep test-plugin
  *test-plugin* (glob)

  $ antigen-purge test-plugin --force
  Done. Please open a new shell to see the changes.
