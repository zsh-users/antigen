Use unknown library.

  $ antigen-use unknown
  Usage: antigen-use <library-name>
  Where <library-name> is any one of the following:
   * oh-my-zsh
   * prezto
  [1]

Missing argument.

  $ antigen-use
  Usage: antigen-use <library-name>
  Where <library-name> is any one of the following:
   * oh-my-zsh
   * prezto
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
