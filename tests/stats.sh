#!/usr/bin/zsh
PROJECT=${1:-$HOME}
SHELL=${2:-zsh}
ZSHRC=$HOME/.zshrc
TMP=${ZSHRC}.stats-tmp
CMD="$SHELL -ic exit"
MTIME=/tmp/mtime

# Back up configuration
cp $ZSHRC $TMP 

cp $PROJECT/tests/.zshrc $HOME/.zshrc
echo Installing bundles...
eval "$SHELL -ic 'rm $HOME/.antigen/init.zsh'"
eval "$SHELL -ic 'rm -rf $HOME/.antigen/repos/'"
eval $CMD
echo Done.
echo

echo Installed bundles:
eval "$SHELL -ic 'source $PROJECT/antigen.zsh; antigen list'"
echo

echo Performance testing...
for x in $(seq 1 20); do
    (eval time $CMD) &>> $MTIME
    tail -1 $MTIME
done

echo
awk '{ total += $10; user += $4; sys += $6; count++ } END {  printf "\nAverage:\ntotal %.3fs user %.3fs sys %.3fs\n", total/count, user/count, sys/count }' $MTIME

echo Done.

rm -f $MTIME
cp $TMP $ZSHRC
