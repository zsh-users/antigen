Should respect load spec.

  $ -antigen-load-source () {
  >  echo ${(j:\n:)list}
  > }

Must load all .zsh found:

  $ antigen bundle $PLUGIN_DIR
  Installing .*/test-plugin... Done. Took .*s. (re)
  *aliases.zsh (glob)
  $ echo ${(j:\n:)PATH}
  .*/test-plugin (re)

Must load all single .zsh:

  $ antigen bundle $PLUGIN_DIR aliases.zsh
  *aliases.zsh (glob)
  $ echo ${(j:\n:)PATH}
  .*/test-plugin (re)


Must load single theme:

  $ antigen bundle $PLUGIN_DIR silly.zsh-theme
  *silly.zsh-theme (glob)
  $ echo ${(j:\n:)PATH}
  .*/test-plugin (re)

Must load single init.zsh:

  $ antigen bundle $PLUGIN_DIR2
  Installing .*/test-plugin2... Done. Took .*s. (re)
  *init.zsh (glob)
  $ echo ${(j:\n:)PATH}
  .*/test-plugin2 (re)

Must add plugin directory to PATH:

  $ antigen bundle $PLUGIN_DIR3
  Installing .*/test-plugin3... Done. Took .*s. (re)
  
  $ echo ${(j:\n:)PATH}
  .*/test-plugin3 (re)

Handle non-git plugin:

  $ antigen bundle $PLUGIN_DIR4
  
  $ echo ${(j:\n:)PATH}
  .*/test-plugin4 (re)

Can load from version:

  $ -antigen-load-source () {
  >  echo ${(j:\n:)list}
  >  source ${list}
  > }

  $ antigen bundle "$PLUGIN_DIR5@v1.*"
  Installing .*/test-plugin5@v1.*... Done. Took .*s. (re)
  .*test-plugin5-v1.x///version.zsh (re)
  $ echo ${(j:\n:)PATH}
  .*/test-plugin5-v1.* (re)

  $ echo $VERSION
  v1.1.4

  $ antigen bundle "$PLUGIN_DIR5@v0.0.*"
  Installing .*/test-plugin5@v0.0.*... Done. Took .*s. (re)
  .*test-plugin5-v0.0.x///version.zsh (re)
  $ echo ${(j:\n:)PATH}
  .*/test-plugin5-v0.0.x (re)

  $ echo $VERSION
  v0.0.2

  $ antigen bundle "$PLUGIN_DIR5@v*"
  Installing .*/test-plugin5@v.*... Done. Took .*s. (re)
  .*test-plugin5-vx///version.zsh (re)
  $ echo ${(j:\n:)PATH}
  .*/test-plugin5-vx (re)

  $ echo $VERSION
  v3

  $ antigen bundle "$PLUGIN_DIR5@v0.0.1"
  Installing .*/test-plugin5@v0.0.1... Done. Took .*s. (re)
  .*test-plugin5-v0.0.1///version.zsh (re)
  $ echo ${(j:\n:)PATH}
  .*/test-plugin5-v0.0.1 (re)

  $ echo $VERSION
  v0.0.1

  $ antigen bundle "$PLUGIN_DIR5@stable"
  Installing .*/test-plugin5@stable... Done. Took .*s. (re)
  .*test-plugin5-stable///version.zsh (re)
  $ echo ${(j:\n:)PATH}
  .*/test-plugin5-stable (re)

  $ echo $VERSION
  initial

  $ antigen bundle "$PLUGIN_DIR5"
  Installing .*/test-plugin5... Done. Took .*s. (re)
  .*test-plugin5///version.zsh (re)
  $ echo ${(j:\n:)PATH}
  .*/test-plugin5 (re)

  $ echo $VERSION
  v3
