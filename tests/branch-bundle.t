Setup a plugin.

  $ mkdir plugin

A git wrapper that works with the plugin's repo.

  $ pg () {
  >   git --git-dir plugin/.git --work-tree plugin "$@"
  > }

Setup the plugin repo.

  $ pg init
  Initialized empty Git repository in .+?/plugin/\.git/? (re)

Master branch content.

  $ cat > plugin/aliases.zsh <<EOF
  > alias hehe='echo hehe'
  > EOF
  $ pg add .
  $ pg commit -m 'Initial commit'
  \[master \(root-commit\) [a-f0-9]{7}\] Initial commit (re)
   1 file changed, 1 insertion(+)
   create mode [\d]{6} aliases\.zsh (re)

Branch b1.

  $ pg branch b1
  $ pg checkout b1
  Switched to branch 'b1'
  $ cat > plugin/aliases.zsh <<EOF
  > alias hehe='echo hehe from b1'
  > EOF
  $ pg commit -am 'Change for b1'
  \[b1 [a-f0-9]{7}\] Change for b1 (re)
   1 file changed, 1 insertion(+), 1 deletion(-)

Go back to master.

  $ pg checkout master
  Switched to branch 'master'

Load plugin from b1.

  $ antigen-bundle $PWD/plugin --branch=b1
  Cloning into '.+?'\.\.\. (re)
  done.
  Switched to a new branch 'b1'
  Branch b1 set up to track remote branch b1 from origin.
  $ hehe
  hehe from b1

Load plugin from master.

  $ antigen-bundle $PWD/plugin
  Cloning into '.+?'\.\.\. (re)
  done.
  $ hehe
  hehe
