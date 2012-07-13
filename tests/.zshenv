# zshrc file written for antigen's tests. Might not be a good one for daily use.

# See cram's documentation for some of the variables used below.

default_clone="/tmp/antigen-tests-clone-cache"

if [[ ! -d "$default_clone" ]]; then
    git clone https://github.com/robbyrussell/oh-my-zsh.git "$default_clone"
fi

export ANTIGEN_DEFAULT_REPO_URL="$default_clone"
export ADOTDIR="$PWD/dot-antigen"

rm "$TESTDIR/.zcompdump"

source "$TESTDIR/../antigen.zsh"
