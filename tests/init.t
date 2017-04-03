Can source an dot-antigenrc file:

  $ zcache-cache-exists () { false }
  $ source () { echo $1 }
  $ antigen-init $ANTIGEN/tests/.antigenrc
  .*/.antigenrc (re)

Returns error if non-existing file is given:

  $ zcache-cache-exists () { false }
  $ antigen-init /non-existing/file.zsh
  Antigen: invalid argument provided.
  [1]

Can handle heredocs:

  $ zcache-cache-exists () { false }
  $ antigen () { echo $@ }
  $ antigen-init <<EOB
  > antigen use library
  > antigen bundle bundle/name
  > antigen apply
  > EOB
  use library
  bundle bundle/name
  apply
