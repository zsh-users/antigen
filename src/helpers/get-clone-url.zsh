-antigen-get-clone-url () {
  # Takes a repo's clone dir and unmangles it, to give the repo's original url
  # that was used to create the given directory path.

  local _path="${1}"
  _path=${_path//^\$ADOTDIR\/repos\/}
  _path=${_path//-SLASH-/\/}
  _path=${_path//-COLON-/\:}
  _path=${_path//-STAR-/\*}
  echo "${_path//-PIPE-/\|}"
}

