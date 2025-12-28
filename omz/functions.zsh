# functions

#######################################
# update all mirrored puppet forge modules in the current directory
# Arguments:
#   None
# Outputs:
#   Writes the git fetch and push status to stdout
#######################################
function update_forge_modules () {
  for dir in $(ls -1); do
    echo $dir
    git -C "$dir" fetch -p origin
    git -C "$dir" push --mirror
    echo
    echo
  done
}
