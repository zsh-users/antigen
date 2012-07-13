Load plugin from master.

  $ antigen-bundle $PWD/test-plugin
  Cloning into '.+?'\.\.\. (re)
  done.
  $ hehe
  hehe

Update the plugin.

  $ cat > test-plugin/aliases.zsh <<EOF
  > alias hehe='echo hehe, updated'
  > EOF
  $ pg commit -am 'Updated message'
  \[master [a-f0-9]{7}\] Updated message (re)
   1 file changed, 1 insertion(+), 1 deletion(-)

Update bundles.

  $ antigen-update
  From .+?/test-plugin (re)
     [a-z0-9]{7}\.\.[a-z0-9]{7}  master     -> origin/master (re)
  Updating [a-z0-9]{7}\.\.[a-z0-9]{7} (re)
  Fast-forward
   aliases.zsh |    2 +-
   1 file changed, 1 insertion(+), 1 deletion(-)

Confirm there is still only one repository.

  $ ls $ADOTDIR/repos | wc -l
  1

The new alias should not activate.

  $ hehe
  hehe
