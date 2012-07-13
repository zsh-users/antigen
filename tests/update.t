Setup a plugin.

  $ mkdir plugin

A git wrapper that works with the plugin's repo.

  $ pg () {
  >   git --git-dir plugin/.git --work-tree plugin "$@"
  > }

Setup the plugin repo.

  $ pg init
  Initialized empty Git repository in .+?/plugin/\.git/? (re)

Write to the plugin.

  $ cat > plugin/aliases.zsh <<EOF
  > alias hehe='echo hehe'
  > EOF
  $ pg add .
  $ pg commit -m 'Initial commit'
  \[master \(root-commit\) [a-f0-9]{7}\] Initial commit (re)
   1 file changed, 1 insertion(+)
   create mode [\d]{6} aliases\.zsh (re)

Load plugin from master.

  $ antigen-bundle $PWD/plugin
  Cloning into '.+?'\.\.\. (re)
  done.
  $ hehe
  hehe

Update the plugin.

  $ cat > plugin/aliases.zsh <<EOF
  > alias hehe='echo hehe, updated'
  > EOF
  $ pg commit -am 'Updated message'
  \[master [a-f0-9]{7}\] Updated message (re)
   1 file changed, 1 insertion(+), 1 deletion(-)

Update bundles.

  $ antigen-update
  From .+?/plugin (re)
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
