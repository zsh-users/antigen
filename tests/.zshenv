# Display all globally defined variables from functions
setopt localoptions warncreateglobal

# zshrc file written for antigen's tests. Might not be a good one for daily use.
# See cram's documentation for some of the variables used below.
export ADOTDIR=$(mktemp -du "/tmp/dot-antigen-tmp-XXXXX")
[[ ! -d "$ADOTDIR" ]] && mkdir -p "$ADOTDIR"

export ANTIGEN=${ANTIGEN:-"/antigen"}
export ANTIGEN_AUTO_CONFIG=false
export ANTIGEN_CACHE=false
export ANTIGEN_RSRC=$ADOTDIR/.resources
export _ANTIGEN_WARN_DUPLICATES=false
export _ANTIGEN_INTERACTIVE=true

# Comment/uncomment this line to be able to see detailed debug logs on
# the tests output (tests naturally will fail)
# export ANTIGEN_DEBUG_LOG=/dev/stdout

export TESTDIR=$(mktemp -d "/tmp/cram-testdir-XXXXX" || /tmp/cram-testdir)
test -f "$TESTDIR/.zcompdump" && rm "$TESTDIR/.zcompdump"
source "$ANTIGEN/antigen.zsh"

# A test plugin repository to test out antigen with.

PLUGIN_DIR="$TESTDIR/test-plugin"
# {
  mkdir "$PLUGIN_DIR"

  # A wrapper function over `git` to work with the test plugin repo.
  alias pg='git --git-dir "$PLUGIN_DIR/.git" --work-tree "$PLUGIN_DIR"'

  echo 'alias hehe="echo hehe"' > "$PLUGIN_DIR"/aliases.zsh
  echo 'PS1="prompt>"' > "$PLUGIN_DIR"/silly.zsh-theme
  echo 'PS1=">"' > "$PLUGIN_DIR"/arrow.zsh-theme

  {
      pg init
      pg config user.name 'test'
      pg config user.email 'test@test.test'
      pg add .
      pg commit -m 'Initial commit'
  } > /dev/null
# }

# Another test plugin.

PLUGIN_DIR2="$TESTDIR/test-plugin2"
# {
  mkdir "$PLUGIN_DIR2"

  # A wrapper function over `git` to work with the test plugin repo.
  alias pg2='git --git-dir "$PLUGIN_DIR2/.git" --work-tree "$PLUGIN_DIR2"'

  echo 'alias hehe2="echo hehe2"' > "$PLUGIN_DIR2"/init.zsh
  echo -E 'alias prompt="\e]$ >\a\n"' >> "$PLUGIN_DIR2"/init.zsh
  echo 'local root=${0}' >> "$PLUGIN_DIR2"/init.zsh
  echo 'function root_source () {
          echo $root/$0
      }' >> "$PLUGIN_DIR2"/init.zsh
  echo 'alias unsourced-alias="echo unsourced-alias"' > "$PLUGIN_DIR2"/aliases.zsh

  {
      pg2 init
      pg2 config user.name 'test'
      pg2 config user.email 'test@test.test'
      pg2 add .
      pg2 commit -m 'Initial commit'
  } > /dev/null
# }

# Another test plugin.

PLUGIN_DIR3="$TESTDIR/test-plugin3"
# {
  mkdir "$PLUGIN_DIR3"

  # A wrapper function over `git` to work with the test plugin repo.
  alias pg3='git --git-dir "$PLUGIN_DIR3/.git" --work-tree "$PLUGIN_DIR3"'

  echo "echo '######'" > "$PLUGIN_DIR3"/hr-plugin
  chmod u+x "$PLUGIN_DIR3"/hr-plugin

  {
      pg3 init
      pg3 config user.name 'test'
      pg3 config user.email 'test@test.test'
      pg3 add .
      pg3 commit -m 'Initial commit'
  } > /dev/null
# }

PLUGIN_DIR4="$TESTDIR/test-plugin4"
# {
  mkdir "$PLUGIN_DIR4"
  echo "echo hello world" > "$PLUGIN_DIR4/hello-world"
  chmod u+x "$PLUGIN_DIR4/hello-world"
# }

# Another test plugin.

PLUGIN_DIR5="$TESTDIR/test-plugin5"
# {
  mkdir "$PLUGIN_DIR5"

  # A wrapper function over `git` to work with the test plugin repo.
  alias pg3='git --git-dir "$PLUGIN_DIR5/.git" --work-tree "$PLUGIN_DIR5"'

  {
      pg3 init
      pg3 config user.name 'test'
      pg3 config user.email 'test@test.test'
      
      echo "export VERSION='initial'" > "$PLUGIN_DIR5/version.zsh"
      pg3 add .
      pg3 commit -m 'Initial commit'
      pg3 branch stable
      
      echo "export VERSION='v0.0.1'" > "$PLUGIN_DIR5/version.zsh"
      pg3 add .
      pg3 commit -m 'v0.0.1'
      pg3 tag v0.0.1

      echo "export VERSION='v0.0.2'" > "$PLUGIN_DIR5/version.zsh"
      pg3 add .
      pg3 commit -m 'v0.0.2'
      pg3 tag v0.0.2
      
      echo "export VERSION='v1.0.3'" > "$PLUGIN_DIR5/version.zsh"
      pg3 add .
      pg3 commit -m 'v1.0.3'
      pg3 tag v1.0.3
      
      echo "export VERSION='v1.1.4'" > "$PLUGIN_DIR5/version.zsh"
      pg3 add .
      pg3 commit -m 'v1.1.4'
      pg3 tag v1.1.4
      
      echo "export VERSION='v3'" > "$PLUGIN_DIR5/version.zsh"
      pg3 add .
      pg3 commit -m 'v3'
      pg3 tag v3
  } > /dev/null
# }

# Wrapper around \wc command to handle wc format differences between GNU and BSD
# GNU:
#  echo 1 | wc -l
#  1
# BSD:
#  echo 1 | wc -l
#       1
#
# Using this wrapper output from both implementations resembles GNU's.
function wc () {
    command wc "$@" | xargs
}
