Enable extension.

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

  $ ls $_ZCACHE_PAYLOAD_PATH | wc -l
  1

Should have listed bundles.

  $ antigen list | wc -l
  2

  $ ls -A ${_ZCACHE_PAYLOAD_PATH:A:h} | wc -l
  3

Should not leak Antigen or OMZ environment variables.

  $ env | sed -e 's/\=.*//' | grep -i antigen | wc -l
  0

  $ env | sed -e 's/\=.*//' | grep -i zsh | wc -l
  0

Both bundles are cached by bundle.

  $ _ZCACHE_EXTENSION_BUNDLE=true
  $ antigen reset > /dev/null

  $ echo "$PLUGIN_DIR\n$PLUGIN_DIR2" | antigen bundles > /dev/null
  $ antigen apply > /dev/null

  $ cat $_ZCACHE_PAYLOAD_PATH | grep hehe
  alias hehe="echo hehe"
  alias hehe2="echo hehe2"

Both bundles are cached by reference.

  $ _ZCACHE_EXTENSION_BUNDLE=false
  $ antigen reset &> /dev/null
  $ echo "$PLUGIN_DIR\n$PLUGIN_DIR2" | antigen bundles
  $ antigen apply &> /dev/null

  $ cat $_ZCACHE_PAYLOAD_PATH | grep source
  antigen.* (re)
  source .*-SLASH-test-plugin//aliases.zsh.* (re)
  source .*-SLASH-test-plugin2//init.zsh.* (re)

List command should work as expected.

  $ antigen list
  .*/test-plugin @ master (re)
  .*/test-plugin2 @ master (re)

Respect escape sequences.

  $ _ZCACHE_EXTENSION_BUNDLE=true
  $ antigen reset > /dev/null

  $ echo "$PLUGIN_DIR\n$PLUGIN_DIR2" | antigen bundles > /dev/null
  $ antigen apply > /dev/null

  $ cat $_ZCACHE_PAYLOAD_PATH | grep 'alias prompt'
  alias prompt="\e]$ >\a\n"

Cache is saved correctly.

  $ cat $_ZCACHE_PAYLOAD_PATH | grep -c 'alias prompt'
  1

  $ cat $_ZCACHE_PAYLOAD_PATH | grep -c 'root=\${__ZCACHE_FILE_PATH}'
  1

  $ cat $_ZCACHE_PAYLOAD_PATH | grep -c 'echo \$root/\$0'
  1

Cache version matches antigen version.

  $ source $_ZCACHE_PAYLOAD_PATH
  $ ANTIGEN_VERSION=$(antigen version | sed 's/Antigen //')
  $ cat $_ZCACHE_PAYLOAD_PATH | grep -c "$ANTIGEN_VERSION"
  2

  $ if [[ "$ANTIGEN_VERSION" == "$_ZCACHE_CACHE_VERSION" ]]; then echo 1; else echo 0; fi
  1

Can clear cache correctly.

  $ antigen reset
  Done. Please open a new shell to see the changes.

  $ [[ -f $_ZCACHE_PAYLOAD_PATH ]]
  [1]
