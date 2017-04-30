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
  Installing bundle/unexisting... Error! Activate logging and try again.
  [1]
  $ echo $fpath | grep -co test-plugin
  1

Confirm bundle/unexisting does not exists (parent directory will not be removed).

  $ ls $ANTIGEN_BUNDLES/bundle/ | wc -l
  0

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

  $ echo ${(j:\n:)fpath}
  .*/site-functions (re)
  .*/functions (re)
  .*/test-plugin (re)
  .*/test-plugin2 (re)

Load plugin multiple times, doesn't cluters _ANTIGEN_BUNDLE_RECORD

  $ antigen-bundle $PLUGIN_DIR
  $ echo ${(j:\n:)_ANTIGEN_BUNDLE_RECORD} | wc -l
  2
  $ antigen-bundle $PLUGIN_DIR
  $ echo ${(j:\n:)_ANTIGEN_BUNDLE_RECORD} | wc -l
  2

Bundle short names.

  $ -antigen-bundle-short-name "https://github.com/example/bundle.git"
  example/bundle

Branch name is not display with short names.

  $ -antigen-bundle-short-name "https://github.com/example/bundle.git|branch"
  example/bundle

  $ -antigen-bundle-short-name "https://github.com/example/bundle.git|feature/branch/git"
  example/bundle

  $ -antigen-bundle-short-name "https://github.com/example/bundle.git" "feature/branch/git"
  example/bundle@feature/branch/git

  $ -antigen-bundle-short-name "example/bundle.git" "feature/branch.git"
  example/bundle@feature/branch.git

  $ -antigen-bundle-short-name "example/bundle" "feature/branch.git"
  example/bundle@feature/branch.git

Handle shorter syntax.

  $ -antigen-bundle-short-name "github.com/example/bundle"
  example/bundle

Handle local bundles (--no-local-clone).

  $ -antigen-bundle-short-name "/home/user/local-bundle"
  user/local-bundle

Load a binary bundle.

  $ antigen-bundle $PLUGIN_DIR3 &> /dev/null
  $ hr-plugin
  ######

  $ echo $PATH | grep test-plugin3
  *plugin3* (glob)

Warns about duplicate bundle.

  $ antigen-bundle $PLUGIN_DIR3 &> /dev/null
  $ _ANTIGEN_WARN_DUPLICATES=true
  $ antigen-bundle $PLUGIN_DIR3
  Seems .* is already installed! (re)
  [1]

  $ _ANTIGEN_WARN_DUPLICATES=false
  $ antigen-theme $PLUGIN_DIR silly &> /dev/null
  $ _ANTIGEN_WARN_DUPLICATES=true
  $ antigen-theme $PLUGIN_DIR silly
  Seems .* is already installed! (re)
  [1]
