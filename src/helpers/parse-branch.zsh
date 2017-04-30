# Parses and retrieves a remote branch given a branch name.
#
# If the branch name contains '*' it will retrieve remote branches
# and try to match against tags and heads, returning the latest matching.
#
# Usage
#     -antigen-parse-branch https://github.com/user/repo.git x.y.z
#
# Returns
#     Branch name
-antigen-parse-branch () {
  local url="$1" branch="$2" branches
  
  local match mbegin mend MATCH MBEGIN MEND

  if [[ "$branch" =~ '\*' ]]; then
    branches=$(git ls-remote --tags -q "$url" "$branch"|cut -d'/' -f3|sort -n|tail -1)
    # There is no --refs flag in git 1.8 and below, this way we
    # emulate this flag -- also git 1.8 ref order is undefined.
    branch=${${branches#*/*/}%^*} # Why you are like this?
  fi

  echo $branch
}
