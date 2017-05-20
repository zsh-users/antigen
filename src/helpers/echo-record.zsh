# Echo the bundle specs as in the record. The first line is not echoed since it
# is a blank line.
-antigen-echo-record () {
  echo ${(j:\n:)_ANTIGEN_BUNDLE_RECORD}
}
