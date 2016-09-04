source $ANTIGEN/antigen.zsh

if [[ "$_ANTIGEN_INIT_ENABLED" == "true" ]]; then
  antigen init $ANTIGEN/tests/.antigenrc
else
  source $ANTIGEN/tests/.antigenrc
fi
