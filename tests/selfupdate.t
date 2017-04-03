Set environment variables for this test case

  $ TEST_DIR=$PWD
  $ TEST_HOST=$TEST_DIR/host
  $ TEST_NORMAL=$TEST_DIR/client
  $ TEST_SUBMODULE=$TEST_DIR/submodule

Create fake host repository

  $ mkdir -p $TEST_HOST
  $ cd $TEST_HOST
  $ git init
  Initialized empty Git repository in * (glob)
  $ git config user.name 'test'
  $ git config user.email 'test@test.test'
  $ echo 1 > ver
  $ git add ver
  $ git commit -m "1"
  [master (root-commit) ???????] 1 (glob)
   1 file changed, 1 insertion(+)
   create mode 100644 ver

Create a normal repository cloning from host

  $ git clone $TEST_HOST $TEST_NORMAL &> /dev/null

Create a submodule repository cloning from host

  $ mkdir -p $TEST_SUBMODULE
  $ cd $TEST_SUBMODULE
  $ git init
  Initialized empty Git repository in * (glob)
  $ git config user.name 'test'
  $ git config user.email 'test@test.test'
  $ git submodule add $TEST_HOST antigen &> /dev/null
  $ git commit -m "1"
  [master (root-commit) ???????] 1 (glob)
   2 files changed, 4 insertions(+)
   create mode 100644 .gitmodules
   create mode 160000 antigen

Update host repository

  $ cd $TEST_HOST
  $ echo 2 > ver
  $ git add ver
  $ git commit -m "2"
  [master ???????] 2 (glob)
   1 file changed, 1 insertion(+), 1 deletion(-)

Use selfupdate from normal repository

  $ _ANTIGEN_INSTALL_DIR=$TEST_NORMAL antigen-selfupdate
  From * (glob)
     ???????..???????  master     -> origin/master (glob)
  Updating ???????..??????? (glob)
  Fast-forward
   ver |*2 +- (glob)
   1 file changed, 1 insertion(+), 1 deletion(-)
  $ _ANTIGEN_INSTALL_DIR=$TEST_NORMAL antigen-selfupdate
  Already up-to-date.

Use selfupdate from submodule repository

  $ _ANTIGEN_INSTALL_DIR=$TEST_SUBMODULE/antigen antigen-selfupdate
  From * (glob)
     ???????..???????  master     -> origin/master (glob)
  Updating ???????..??????? (glob)
  Fast-forward
   ver |*2 +- (glob)
   1 file changed, 1 insertion(+), 1 deletion(-)
  $ _ANTIGEN_INSTALL_DIR=$TEST_SUBMODULE/antigen antigen-selfupdate
  Already up-to-date.
