#!/bin/bash
# Build and install zsh version from source

# Version to test against, ex. ZSH_VERSION=master
ZSH_VERSION=$1
[ -z "$ZSH_VERSION" ] && echo "Error: No zsh version specified." && exit 1;

# Base path for compiled zsh binaries, ex. /bin/zsh-builds
BUILDS_PATH=$2
[ -z "$BUILDS_PATH" ] && echo "Error: No zsh builds path specified." && exit 2;

# Base path where to clone zsh repository
ZSH_SOURCE=$3
[ -z "$ZSH_SOURCE" ] && echo "Error: No zsh source path specified." && exit 3;

# Install dev tools (already installed in travis environment)
# apt-get install -y git-core gcc make autoconf yodl libncursesw5-dev texinfo checkinstall

# Get the code. Should cache it.
[ ! -e zsh ] && git clone $ZSH_REMOTE_URL $ZSH_SOURCE
cd $ZSH_SOURCE

# Build version
# Be sure to clean everything
make clean
git clean -fd
git checkout -- .

# Check out with branch to build, ie: master, zsh-5.0.1, etc
git checkout $ZSH_VERSION

# Make configure
./Util/preconfig

# Configure bindir for this branch
./configure --bindir=$BUILDS_PATH/$ZSH_VERSION --prefix=$BUILDS_PATH/$ZSH_VERSION

# Make
make -j5

make install

cd -
