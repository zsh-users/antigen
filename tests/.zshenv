# zshrc file written for antigen's tests. Might not be a good one for daily use.

# Clean the environment from CI so that environment tests will pass.

unset ZSH_REMOTE_URL
unset ZSH_SOURCE
unset ZSH_BUILD_VERSION

# Removes travis commit message that may interfere with env-leak tests.
# See https://gitter.im/antigen-zsh/develop?at=58c35d257ceae5376a9f859a
unset TRAVIS_COMMIT_MESSAGE

# See cram's documentation for some of the variables used below.

ADOTDIR="$PWD/dot-antigen"
[[ ! -d "$ADOTDIR" ]] && mkdir -p "$ADOTDIR"

_ANTIGEN_CACHE_ENABLED=true
_ANTIGEN_INTERACTIVE_MODE=true
_ZCACHE_EXTENSION_CLEAN_FUNCTIONS=false
_ANTIGEN_BUNDLE_RECORD=""
_ANTIGEN_LOG_PATH=/tmp/antigen.log

test -f "$TESTDIR/.zcompdump" && rm "$TESTDIR/.zcompdump"

source "$TESTDIR/../antigen.zsh"

# A test plugin repository to test out antigen with.

PLUGIN_DIR="$PWD/test-plugin"
mkdir "$PLUGIN_DIR"

# A wrapper function over `git` to work with the test plugin repo.
alias pg='git --git-dir "$PLUGIN_DIR/.git" --work-tree "$PLUGIN_DIR"'

echo 'alias hehe="echo hehe"' > "$PLUGIN_DIR"/aliases.zsh
echo 'PS1="prompt>"' > "$PLUGIN_DIR"/silly.zsh-theme
echo 'PS1=">"' > "$PLUGIN_DIR"/arrow.zsh-theme

{
    pg init
    pg add .
    pg commit -m 'Initial commit'
} > /dev/null

# Another test plugin.

PLUGIN_DIR2="$PWD/test-plugin2"
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
    pg2 add .
    pg2 commit -m 'Initial commit'
} > /dev/null

# Another test plugin.

export PLUGIN_DIR3="$PWD/test-plugin3"
mkdir "$PLUGIN_DIR3"

# A wrapper function over `git` to work with the test plugin repo.
alias pg3='git --git-dir "$PLUGIN_DIR3/.git" --work-tree "$PLUGIN_DIR3"'

echo "echo '######'" > "$PLUGIN_DIR3"/hr-plugin
chmod u+x "$PLUGIN_DIR3"/hr-plugin

{
    pg3 init
    pg3 add .
    pg3 commit -m 'Initial commit'
} > /dev/null

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

