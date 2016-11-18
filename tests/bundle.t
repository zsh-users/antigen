Should get a complain if no bundle is given as argument.

  $ antigen-bundle
  Must provide a bundle url or name.
  [1]

Load plugin from master.

  $ antigen-bundle $PLUGIN_DIR &> /dev/null
  $ hehe
  hehe

Load the plugin again. Just to see nothing happens.

  $ antigen-bundle $PLUGIN_DIR
  $ hehe
  hehe

Confirm there is still only one repository.

  $ ls $ADOTDIR/repos | wc -l
  1

Load a prezto style module. Should only source the `init.zsh` present in the
module.

  $ antigen-bundle $PLUGIN_DIR2 &> /dev/null
  $ hehe2
  hehe2

The alias defined in the other zsh file should not be available.

  $ unsourced-alias
  zsh: command not found: unsourced-alias
  [127]

Fpath should be updated correctly.

  $ echo ${(j:\n:)fpath} | grep -Pco test-plugin
  2

Load plugin multiple times, doesn't cluters _ANTIGEN_BUNDLE_RECORD

  $ antigen-bundle $PLUGIN_DIR
  $ echo $_ANTIGEN_BUNDLE_RECORD | wc -l
  3
  $ antigen-bundle $PLUGIN_DIR
  $ echo $_ANTIGEN_BUNDLE_RECORD | wc -l
  3