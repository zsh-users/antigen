# zshrc file written for antigen's tests. Might not be a good one for daily use.

# See cram's documentation for some of the variables used below.

export ADOTDIR="$PWD/dot-antigen"
[[ ! -d "$ADOTDIR" ]] && mkdir -p "$ADOTDIR"

export _ANTIGEN_CACHE_ENABLED=true
export _ANTIGEN_INTERACTIVE_MODE=true
export _ZCACHE_EXTENSION_CLEAN_FUNCTIONS=false

test -f "$TESTDIR/.zcompdump" && rm "$TESTDIR/.zcompdump"

source "$TESTDIR/../antigen.zsh"

# A test plugin repository to test out antigen with.

export PLUGIN_DIR="$PWD/test-plugin"
mkdir "$PLUGIN_DIR"

# A wrapper function over `git` to work with the test plugin repo.
alias pg='git --git-dir "$PLUGIN_DIR/.git" --work-tree "$PLUGIN_DIR"'

echo 'alias hehe="echo hehe"' > "$PLUGIN_DIR"/aliases.zsh
echo 'export PS1="prompt>"' > "$PLUGIN_DIR"/silly.zsh-theme

{
    pg init
    pg add .
    pg commit -m 'Initial commit'
} > /dev/null

# Another test plugin.

export PLUGIN_DIR2="$PWD/test-plugin2"
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
