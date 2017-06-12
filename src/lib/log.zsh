zmodload zsh/datetime
ANTIGEN_DEBUG_LOG=${ANTIGEN_DEBUG_LOG:-${ADOTDIR:-$HOME/.antigen}/debug.log}
LOG () {
  local PREFIX="[LOG][${EPOCHREALTIME}]"
  echo "${PREFIX} ${funcfiletrace[1]}\n${PREFIX} $@" >> $ANTIGEN_DEBUG_LOG
}

ERR () {
  local PREFIX="[ERR][${EPOCHREALTIME}]"
  echo "${PREFIX} ${funcfiletrace[1]}\n${PREFIX} $@" >> $ANTIGEN_DEBUG_LOG
}

WARN () {
  local PREFIX="[WRN][${EPOCHREALTIME}]"
  echo "${PREFIX} ${funcfiletrace[1]}\n${PREFIX} $@" >> $ANTIGEN_DEBUG_LOG
}

TRACE () {
  local PREFIX="[TRA][${EPOCHREALTIME}]"
  echo "${PREFIX} ${funcfiletrace[1]}\n${PREFIX} $@\n${PREFIX} ${(j:\n:)funcstack}" >> $ANTIGEN_DEBUG_LOG
}
