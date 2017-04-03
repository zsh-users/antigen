Enable extension.

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

Both bundles are cached by bundle.

  $ _ZCACHE_BUNDLE=true
  $ antigen reset > /dev/null

  $ echo "$PLUGIN_DIR\n$PLUGIN_DIR2" | antigen bundles > /dev/null
  $ antigen apply > /dev/null

  $ cat $ANTIGEN_CACHE | grep hehe
  alias hehe="echo hehe"
  alias hehe2="echo hehe2"

Both bundles are cached by reference.

  $ _ZCACHE_BUNDLE=false
  $ antigen reset &> /dev/null
  $ echo "$PLUGIN_DIR\n$PLUGIN_DIR2" | antigen bundles
  $ antigen apply &> /dev/null

  $ cat $ANTIGEN_CACHE | grep source
  .* (re)
  source .*test-plugin/aliases.zsh.* (re)
  source .*test-plugin2/init.zsh.* (re)

List command should work as expected.

  $ antigen list
  .*/test-plugin @ master (re)
  .*/test-plugin2 @ master (re)

Respect escape sequences.

  $ _ZCACHE_BUNDLE=true
  $ antigen reset > /dev/null

  $ echo "$PLUGIN_DIR\n$PLUGIN_DIR2" | antigen bundles > /dev/null
  $ antigen apply > /dev/null

  $ cat $ANTIGEN_CACHE | grep 'alias prompt'
  alias prompt="\e]$ >\a\n"

Cache is saved correctly.

  $ cat $ANTIGEN_CACHE | grep -c 'alias prompt'
  1

  $ cat $ANTIGEN_CACHE | grep -c 'root=\${__ZCACHE_FILE_PATH}'
  1

  $ cat $ANTIGEN_CACHE | grep -c 'echo \$root/\$0'
  1

Cache version matches antigen version.

  $ source $ANTIGEN_CACHE
  $ ANTIGEN_VERSION=$(antigen version | sed 's/Antigen //' | sed 's/ (.*//')
  $ [[ "$ANTIGEN_CACHE_VERSION" == "$ANTIGEN_VERSION" ]] && echo 0 || echo 1
  0

Can clear cache correctly.

  $ antigen reset
  Done. Please open a new shell to see the changes.

  $ [[ -f $ANTIGEN_CACHE ]]
  [1]
