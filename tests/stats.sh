#/bin/sh
PROJECT=${1:-$HOME}
SHELL=${2:-zsh}
ZSHRC=$HOME/.zshrc
TMP=${ZSHRC}.stats-tmp
CMD="$SHELL -ic exit"
MTIME=/tmp/mtime

# Back up configuration
cp $ZSHRC $TMP 

cp $PROJECT/tests/.zshrc $HOME/.zshrc
eval $CMD
for x in $(seq 1 20); do
    /usr/bin/time -f "real %e user %U sys %S" -a -o $MTIME $CMD
    tail -1 $MTIME
done 

awk '{ et += $2; ut += $4; st += $6; count++ } END {  printf "\nAverage:\nreal %.3f user %.3f sys %.3f\n", et/count, ut/count, st/count }' $MTIME

rm -f $MTIME
cp $TMP $ZSHRC
