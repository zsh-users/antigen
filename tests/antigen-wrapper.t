Create a dummy antigen command.

  $ antigen-dummy () {
  >   echo me dummy
  > }

Check the normal way of calling it

  $ antigen-dummy
  me dummy

Call with the wrapper syntax.

  $ antigen dummy
  me dummy

Call with an alias

  $ alias a=antigen
  $ a dummy
  me dummy

Call without arguments should exit with error.

  $ antigen 2>/dev/null
  [1]

Call without arguments should display help message.

  $ antigen 2>&1 | head -n 4
  Antigen .* (re)
  Revision .* (re)
  
  Antigen is a .* (re)
