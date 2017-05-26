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

Add multiple bundles

  $ echo "$PLUGIN_DIR\n$PLUGIN_DIR2" | antigen bundles &> /dev/null
  $ antigen apply &> /dev/null

Check if they are both applied.

  $ hehe
  hehe
  $ hehe2
  hehe2

Should exist cache payload.

  $ ls $ANTIGEN_CACHE | wc -l
  1

Should have listed bundles.

  $ antigen list | wc -l
  2

Should not leak Antigen or OMZ environment variables.

  $ diff <(env) <(echo $prev) | sed -e 's/\=.*//' | grep -i antigen | wc -l
  0

  $ diff <(env) <(echo $prev) | sed -e 's/\=.*//' | grep -i zsh | wc -l
  0

Both bundles are cached.

  $ ANTIGEN_CACHE=$ADOTDIR/init.zsh
  $ -antigen-reset-hooks
  $ export _ANTIGEN_INTERACTIVE=false
  $ antigen ext cache
  $ antigen reset > /dev/null
  $ antigen ext-list
  cache
  $ echo "$PLUGIN_DIR\n$PLUGIN_DIR2" | antigen bundles
  $ antigen apply

  $ cat $ANTIGEN_CACHE | grep source
  .*/antigen.zsh.* (re)
  source '.*test-plugin/aliases.zsh'; (re)
  source '.*test-plugin2/init.zsh'; (re)

List command should work as expected.

  $ antigen list
  .*/test-plugin @ master (re)
  .*/test-plugin2 @ master (re)

Cache version matches antigen version.

  $ source $ANTIGEN_CACHE
  $ ANTIGEN_VERSION=$(antigen version | head -1 | sed 's/Antigen //' | sed 's/ (.*//')
  $ [[ "$ANTIGEN_CACHE_VERSION" == "$ANTIGEN_VERSION" ]] && echo 0 || echo 1
  0

Can clear cache correctly.

  $ antigen reset
  Done. Please open a new shell to see the changes.

  $ [[ -f $ANTIGEN_CACHE ]]
  [1]

  $ ANTIGEN_CACHE=false
