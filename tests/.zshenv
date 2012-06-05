# zshrc file written for antigen's tests. Might not be a good one for daily use.

# See cram's documentation for some of the variables used below.

export ANTIGEN_REPO_CACHE="$TMP/dot-antigen/cache"
export ANTIGEN_BUNDLE_DIR="$TMP/dot-antigen/bundle"

rm "$TESTDIR/.zcompdump"

source "$TESTDIR/../antigen.zsh"
