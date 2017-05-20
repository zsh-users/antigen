Purge command removes a bundle from filesystem.
  $ antigen-bundle $PLUGIN_DIR &> /dev/null
  $ antigen-list | grep test-plugin
  *test-plugin* (glob)

  $ antigen-purge test-plugin --force
  Removing '*test-plugin'. (glob)
  Done. Please open a new shell to see the changes.

Purge command without arguments returns an error message.

  $ antigen-purge
  Antigen: Missing argument.
  [1]

Purge command return an error if bundle is not found.

  $ antigen-purge unexisting-bundle
  Bundle not found in record. Try 'antigen bundle unexisting-bundle' first.
  [1]
