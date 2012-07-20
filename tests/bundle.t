Load plugin from master.

  $ antigen-bundle $PLUGIN_DIR
  Cloning into '.+?'\.\.\. (re)
  done.
  $ hehe
  hehe

Load the plugin again. Just to see nothing happens.

  $ antigen-bundle $PLUGIN_DIR
  $ hehe
  hehe

Update the plugin.

  $ cat > $PLUGIN_DIR/aliases.zsh <<EOF
  > alias hehe='echo hehe, updated'
  > EOF
  $ pg commit -am 'Updated message'
  \[master [a-f0-9]{7}\] Updated message (re)
   1 file changed, 1 insertion(+), 1 deletion(-)

Update bundles.

  $ antigen-update
  **** Pulling */test-plugin (glob)
  From */test-plugin (glob)
     ???????..???????  master     -> origin/master (glob)
  Updating ???????..??????? (glob)
  Fast-forward
   aliases.zsh |    2 +-
   1 file changed, 1 insertion(+), 1 deletion(-)
  

Confirm there is still only one repository.

  $ ls $ADOTDIR/repos | wc -l
  1

The new alias should not activate.

  $ hehe
  hehe
