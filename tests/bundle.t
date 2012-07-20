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

Confirm there is still only one repository.

  $ ls $ADOTDIR/repos | wc -l
  1
