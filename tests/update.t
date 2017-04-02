Load plugin.

  $ antigen-bundle $PLUGIN_DIR &> /dev/null
  $ hehe
  hehe

Update the plugin.

  $ cat > $PLUGIN_DIR/aliases.zsh <<EOF
  > alias hehe='echo hehe, updated'
  > EOF
  $ pg commit -am 'Updated message'
  \[master [a-f0-9]{7}\] Updated message (re)
   1 file changed, 1 insertion(+), 1 deletion(-)

Run antigen's update.

  $ antigen-update
  Updating */test-plugin@master... Done. Took *s. (glob)


Confirm there is still only one repository.

  $ ls $ANTIGEN_BUNDLES | wc -l
  1

The new alias should not activate.

  $ hehe
  hehe

Run update again, with no changes in the origin repo.

  $ antigen-update
  Updating */test-plugin@master... Done. Took *s. (glob)

Load another bundle.
  $ antigen-bundle $PLUGIN_DIR2 &> /dev/null

Run antigen's update for the bundle.

  $ antigen-update $PLUGIN_DIR
  Updating */test-plugin@master... Done. Took *s. (glob)

  $ antigen-update $PLUGIN_DIR2
  Updating */test-plugin2@master... Done. Took *s. (glob)

Run update again, should update both bundles.

  $ antigen-update
  Updating */test-plugin@master... Done. Took *s. (glob)
  Updating */test-plugin2@master... Done. Took *s. (glob)

Trying to update an unexisting bundle gives an error.

  $ antigen-update /tmp/example/non-existing-bundle
  Bundle not found in record. Try 'antigen bundle *' first. (glob)
  [1]

