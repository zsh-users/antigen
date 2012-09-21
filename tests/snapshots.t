Load a couple of plugins.

  $ antigen-bundle $PLUGIN_DIR
  Cloning into '*'... (glob)
  done.
  $ antigen-bundle $PLUGIN_DIR2
  Cloning into '*'... (glob)
  done.

Create a snapshot file.

  $ test -f snapshot-file
  [1]
  $ antigen-snapshot snapshot-file
  $ test -f snapshot-file

See the contents of the snapshot file.

  $ cat snapshot-file
  version='1'; created_on='*'; checksum='*'; (glob)
  .{40} .*-test-plugin (re)
  .{40} .*-test-plugin2 (re)
