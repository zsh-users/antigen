Branch b1.

  $ pg branch b1
  $ pg checkout b1
  Switched to branch 'b1'
  $ cat > test-plugin/aliases.zsh <<EOF
  > alias hehe='echo hehe from b1'
  > EOF
  $ pg commit -am 'Change for b1'
  \[b1 [a-f0-9]{7}\] Change for b1 (re)
   1 file changed, 1 insertion(+), 1 deletion(-)

Go back to master.

  $ pg checkout master
  Switched to branch 'master'

Load plugin from b1.

  $ antigen-bundle $PWD/test-plugin --branch=b1
  Cloning into '.+?'\.\.\. (re)
  done.
  Switched to a new branch 'b1'
  Branch b1 set up to track remote branch b1 from origin.
  $ hehe
  hehe from b1

Load plugin from master.

  $ antigen-bundle $PWD/test-plugin
  Cloning into '.+?'\.\.\. (re)
  done.
  $ hehe
  hehe
