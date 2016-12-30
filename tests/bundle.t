Should get a complain if no bundle is given as argument.

  $ antigen-bundle
  Antigen: Must provide a bundle url or name.
  [1]

Load plugin from master.

  $ antigen-bundle $PLUGIN_DIR &> /dev/null
  $ hehe
  hehe

Load the plugin again. Just to see nothing happens.

  $ antigen-bundle $PLUGIN_DIR
  $ hehe
  hehe

Try to load an unexisting plugin from a cloned bundle.

  $ antigen-bundle $PLUGIN_DIR wrong
  Antigen: Failed to load plugin.
  [1]

Try to install an unexisting bundle.

  $ antigen-bundle https://127.0.0.1/bundle/unexisting.git
  Installing bundle/unexisting... Error! See * (glob)
  [1]
  $ echo $fpath | grep -co test-plugin
  1

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

  $ echo ${(j:\n:)fpath} | grep -co test-plugin
  2

Load plugin multiple times, doesn't cluters _ANTIGEN_BUNDLE_RECORD

  $ antigen-bundle $PLUGIN_DIR
  $ echo $_ANTIGEN_BUNDLE_RECORD | wc -l
  3
  $ antigen-bundle $PLUGIN_DIR
  $ echo $_ANTIGEN_BUNDLE_RECORD | wc -l
  3

Bundle short names.

  $ -antigen-bundle-short-name "https://github.com/example/bundle.git"
  example/bundle

Branch name is not display with short names.

  $ -antigen-bundle-short-name "https://github.com/example/bundle.git|branch"
  example/bundle

Handle shorter syntax.

  $ -antigen-bundle-short-name "github.com/example/bundle"
  example/bundle

Handle local bundles (--no-local-clone).

  $ -antigen-bundle-short-name "/home/user/local-bundle"
  user/local-bundle
