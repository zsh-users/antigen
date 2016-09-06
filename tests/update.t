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
  Updating */test-plugin... Done. Took *s. (glob)


Confirm there is still only one repository.

  $ ls $ADOTDIR/repos | wc -l
  1

The new alias should not activate.

  $ hehe
  hehe

Run update again, with no changes in the origin repo.

  $ antigen-update
  Updating */test-plugin... Done. Took *s. (glob)
