# zshrc file written for antigen's tests. Might not be a good one for daily use.

# See cram's documentation for some of the variables used below.

export ANTIGEN_DEFAULT_REPO_URL=https://github.com/robbyrussell/oh-my-zsh.git
export ADOTDIR="$TMP/dot-antigen"

rm "$TESTDIR/.zcompdump"

source "$TESTDIR/../antigen.zsh"
