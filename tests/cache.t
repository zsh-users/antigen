Enable extension.

  $ export _ANTIGEN_INTERACTIVE=false
  $ antigen ext cache
  $ antigen ext-list
  cache
  $ ANTIGEN_CACHE=$ADOTDIR/init.zsh

  $ prev=$(env)
  $ antigen reset
  Done. Please open a new shell to see the changes.

  $ antigen list
  You don't have any bundles.
  [1]

Can programatically generate cache.

  $ antigen reset &> /dev/null
  $ antigen cache-gen
  $ ls $ADOTDIR/init*
  .*init.zsh.* (re)
  .*init.zsh.zwc* (re)
