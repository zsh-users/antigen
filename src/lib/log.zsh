zmodload zsh/datetime
ANTIGEN_DEBUG_LOG=${ANTIGEN_DEBUG_LOG:-${ADOTDIR:-$HOME/.antigen}/debug.log}
LOG () {
  local PREFIX="[LOG][${EPOCHREALTIME}]"
  echo "${PREFIX} ${(%):-%x:%I}\n${PREFIX} $@\n" >> $ANTIGEN_DEBUG_LOG
}

ERR () {
  local PREFIX="[ERR][${EPOCHREALTIME}]"
  echo "${PREFIX} ${(%):-%x:%I}\n${PREFIX} $@\n" >> $ANTIGEN_DEBUG_LOG
}

WARN () {
  local PREFIX="[WRN][${EPOCHREALTIME}]"
  echo "${PREFIX} ${(%):-%x:%I}\n${PREFIX} $@\n" >> $ANTIGEN_DEBUG_LOG
}

TRACE () {
  local PREFIX="[TRA][${EPOCHREALTIME}]"
  echo "${PREFIX} ${(%):-%x:%I}\n${PREFIX} $@\n${PREFIX} ${(j:\n:)funcstack}\n" >> $ANTIGEN_DEBUG_LOG
}
