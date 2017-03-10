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
  local url=$1
  local branch=$2
  local branches

  if [[ "$branch" =~ '\*' ]]; then
    branches=$(git ls-remote --tag --refs -q $url "$branch"|tail -r|head -n1)
    branch=${branches#*/*/}
  fi

  echo $branch
}
