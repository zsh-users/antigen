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
