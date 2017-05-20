Branch b1.

  $ pg branch b1
  $ pg checkout b1
  Switched to branch 'b1'
  $ cat > $PLUGIN_DIR/aliases.zsh <<EOF
  > alias hehe='echo hehe from b1'
  > EOF
  $ pg commit -am 'Change for b1'
  \[b1 [a-f0-9]{7}\] Change for b1 (re)
   1 file changed, 1 insertion(+), 1 deletion(-)

Go back to master.

  $ pg checkout master
  Switched to branch 'master'

Load plugin from b1.

  $ antigen bundle $PLUGIN_DIR --branch=b1 &> /dev/null
  $ hehe
  hehe from b1

Does not say 'Already on b1' on each session startup.

  $ antigen-bundle $PLUGIN_DIR --branch=b1

Load plugin from master.

  $ antigen-bundle $PLUGIN_DIR &> /dev/null
  $ hehe
  hehe
