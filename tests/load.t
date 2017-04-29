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
