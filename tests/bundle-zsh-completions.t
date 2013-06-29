Set environment variables for this test case

  $ export FPATH_BACKUP=$FPATH
  $ unset FPATH

Add bundle for zsh-users/zsh-completions.

  $ echo "zsh-users/zsh-completions" | antigen-bundles
  Cloning into '.+?'\.\.\. (re)

Check $FPATH variable.

  $ echo $FPATH | perl -pe 's/ /\n/g'
  *https-COLON--SLASH--SLASH-github.com-SLASH-zsh-users-SLASH-zsh-completions.git/src (glob)

clean it all up.

  $ export _ANTIGEN_BUNDLE_RECORD=""
  $ antigen-cleanup --force &> /dev/null

Set environment variables for this test case

  $ export FPATH=$FPATH_BACKUP
  $ unset FPATH_BACKUP=""
