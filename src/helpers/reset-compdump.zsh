# Forces to reset zcompdump file
# Removes $ANTIGEN_COMPDUMPFILE as ${ZDOTDIR:-$HOME}/.zcompdump
# Set $_ANTIGEN_FORCE_RESET_COMPDUMP to true to do so
-antigen-reset-compdump () {
    if [[ $_ANTIGEN_FORCE_RESET_COMPDUMP == true && -f $ANTIGEN_COMPDUMPFILE ]]; then
        rm $ANTIGEN_COMPDUMPFILE
    fi
}
