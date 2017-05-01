Set up

  $ alias hook=antigen-add-hook

Call hook any function.

  $ hello () {
  >   echo Hello.
  > }
  $ hello-fr () {
  >   echo Bonjour.
  > }
  $ hook hello hello-fr replace
  $ hello
  Bonjour.

Fail to create hook function if hooked function doesn't exists.

  $ help-fr () {
  >   echo Help.
  > }
  $ hook help help-fr replace
  Antigen: Function help doesn't exist.
  [1]
  $ help
  zsh: command not found: help
  [127]

Fail to create hook function if hook function doesn't exists.

  $ help () {
  >   echo Help.
  > }
  $ hook help help-de replace
  Antigen: Function help-de doesn't exist.
  [1]
  $ help
  Help.

Can create pre hook functions.

  $ hola () {
  >   echo Hola.
  > }
  $ hola-en () {
  >   echo Hello.
  > }
  $ hook hola hola-en pre
  $ hola
  Hello.
  Hola.

Can create post hook functions.

  $ hola-pr () {
  >   echo Olá.
  > }
  $ hook hola hola-pr post
  $ hola
  Hello.
  Hola.
  Olá.

Can reset all hooks functions.

  $ -antigen-reset-hooks
  $ hola
  Hola.

  $ hook hola hola-en pre
  $ hola
  Hello.
  Hola.

Can add multiple pre/post hook functions.

  $ -antigen-reset-hooks
  $ antigen-bundle () {
  >   echo called antigen-bundle with $@
  > }
  $ antigen-bundle desyncr/zsh-ctrlp --no-local-clone
  called antigen-bundle with desyncr/zsh-ctrlp --no-local-clone
  $ antigen-bundle-hook () {
  >   echo "pre-hook: $@"
  > }
  $ hook antigen-bundle antigen-bundle-hook pre
  $ antigen-bundle-hook2 () {
  >   echo "pre-hook2: $@"
  > }
  $ hook antigen-bundle antigen-bundle-hook2 pre
  $ antigen-bundle-hook-post () {
  >   echo "post-hook: $@"
  > }
  $ hook antigen-bundle antigen-bundle-hook-post post
  $ antigen-bundle-hook-post2 () {
  >   echo "post-hook2: $@"
  > }
  $ hook antigen-bundle antigen-bundle-hook-post2 post
  $ antigen-bundle example/bundle
  pre-hook: example/bundle
  pre-hook2: example/bundle
  called antigen-bundle with example/bundle
  post-hook: example/bundle
  post-hook2: example/bundle

Example deferred function with hook.

  $ -antigen-reset-hooks
  $ typeset -a _bundle_deferred; _bundle_deferred=()
  $ antigen-bundle-deferred () {
  >   _bundle_deferred+=($@)
  > }
  $ hook antigen-bundle antigen-bundle-deferred replace
  $ antigen-bundle zsh-users/zsh-syntax-highlighting
  $ antigen-bundle zsh-users/zsh-autocompletions
  $ echo $_bundle_deferred
  zsh-users/zsh-syntax-highlighting zsh-users/zsh-autocompletions
  $ antigen-remove-hook antigen-bundle-deferred
  $ antigen-bundle zsh-users/zsh-completions
  called antigen-bundle with zsh-users/zsh-completions
