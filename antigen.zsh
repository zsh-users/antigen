_ANTIGEN_INSTALL_DIR=${0:A:h}
source $_ANTIGEN_INSTALL_DIR/bin/antigen.zsh
ANTIGEN_CONFIG_FILE=~/.antigenrc
if [ -f "$ANTIGEN_CONFIG_FILE" ]; then
    antigen init "$ANTIGEN_CONFIG_FILE"
fi
