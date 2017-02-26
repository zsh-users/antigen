Use url library.
  $ antigen-bundle () { echo $@ }
  $ antigen-use https://github.com/zsh-users/prezto.git
  https://github.com/zsh-users/prezto.git
  $ echo $ANTIGEN_DEFAULT_REPO_URL
  https://github.com/zsh-users/prezto.git

Accept antigen-bundle semantics.
  $ antigen-bundle () { echo $@ }
  $ antigen-use https://github.com/zsh-users/prezto.git --loc=lib
  https://github.com/zsh-users/prezto.git --loc=lib

Missing argument.

  $ antigen-use
  Usage: antigen-use <library-name|url>
  Where <library-name> is any one of the following:
   * oh-my-zsh
   * prezto
  <url> is the full url.
  [1]

Mock out the library loading functions.

  $ -antigen-use-oh-my-zsh () { echo Using oh-my-zsh. }
  $ -antigen-use-prezto () { echo Using prezto. }

Note: We lack tests for these internal functions. I'm not sure how feasible
testing them is given they most certainly use the network.

Use oh-my-zsh library.

  $ antigen-use oh-my-zsh
  Using oh-my-zsh.

Use prezto library.

  $ antigen-use prezto
  Using prezto.
