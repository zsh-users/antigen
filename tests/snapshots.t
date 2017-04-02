Load a couple of plugins.

  $ antigen-bundle $PLUGIN_DIR &> /dev/null
  $ antigen-bundle $PLUGIN_DIR2 &> /dev/null

Create a snapshot file.

  $ test -f snapshot-file
  [1]
  $ antigen-snapshot snapshot-file
  $ test -f snapshot-file

See the contents of the snapshot file.

  $ cat snapshot-file
  version='1'; created_on='*'; checksum='*'; (glob)
  .{40} .*/test-plugin (re)
  .{40} .*/test-plugin2 (re)

Reset the antigen's bundle record and run cleanup.

  $ unset _ANTIGEN_BUNDLE_RECORD
  $ antigen-cleanup --force | grep '^Deleting' | wc -l
  2

Restore from the snapshot.

  $ ls $ANTIGEN_BUNDLES/cram-testdir-* | wc -l
  0
  $ antigen-restore snapshot-file
  Restoring from snapshot-file... done.
  Please open a new shell to get the restored changes.

  $ ls $ANTIGEN_BUNDLES/* | wc -l
  2
