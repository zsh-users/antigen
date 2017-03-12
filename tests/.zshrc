source $ANTIGEN/antigen.zsh

if [[ "$STATS_USE_INIT" == "true" ]]; then
  antigen init $ANTIGEN/tests/.antigenrc
else
  source $ANTIGEN/tests/.antigenrc
fi
