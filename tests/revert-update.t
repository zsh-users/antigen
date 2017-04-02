Load and test plugin.

  $ antigen-bundle $PLUGIN_DIR &> /dev/null
  $ hehe
  hehe

Save the current HEAD of the plugin.

  $ old_version="$(pg rev-parse HEAD)"

Modify the plugin.

  $ cat > $PLUGIN_DIR/aliases.zsh <<EOF
  > alias hehe='echo hehe, updated'
  > EOF
  $ pg commit -am 'Updated message'
  \[master [a-f0-9]{7}\] Updated message (re)
   1 file changed, 1 insertion(+), 1 deletion(-)

Save the new HEAD of the plugin.

  $ new_version="$(pg rev-parse HEAD)"

Define a convenience function to get the current version.

  $ current-version () {(cd $ANTIGEN_BUNDLES/*/* && git rev-parse HEAD)}

Confirm we currently have the old version.

  $ [[ $(current-version) == $old_version ]]

Run antigen's update.

  $ antigen-update
  Updating */test-plugin@master... Done. Took *s. (glob)

Confirm we have the new version.

  $ [[ $(current-version) == $new_version ]]

Run update again, with no changes in the origin repo.

  $ antigen-revert
  Reverted to state before running -update on *. (glob)

Confirm we have the old version again.

  $ [[ $(current-version) == $old_version ]]
