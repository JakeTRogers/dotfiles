# functions

#######################################
# ssh to the server, concatenate the sudo files, and calculate the resulting SHA1 hash
# Arguments:
#   $1 - hostname of the server to ssh into
# Outputs:
#   Writes the server hostname and resulting SHA1 hash to stdout
#######################################
function getsudohash() {
  if [[ $1 == "--help" || $1 == "-h" || $1 == "-?" ]]; then
    echo "Usage: getsudohash [ hostname ]"
    echo -e "Purpose: ssh to server and report hash"
    echo "Example 1:"
    echo -e "  server> getsudohash SOME_SERVER\n"
  else
    ssh ${1} 'sha1sum <(sudo cat $(sudo find /etc/sudoers.d -type f -print | sort) /etc/sudoers) | colrm 41 | sed "s/^/$(hostname)\t/"'
  fi
}


#######################################
# check child directories for pull requests using the GitHub CLI
# Arguments:
#   None
# Outputs:
#   Writes any existing GitHub pull requests to stdout
#######################################
function git-pr-check() {
  if [[ $1 == "--help" || $1 == "-h" || $1 == "-?" ]]; then
    echo "Usage: git-pr-check [ --help ]"
    echo -e "Purpose: check child directories for pull requests"
    echo "Example 1:"
    echo -e "  server> git-pr-check\n"
    return
  fi
  for dir in $(find . -mindepth 1 -maxdepth 1 -type d -printf '%P\n'); do
    cd "$dir"
    # has a .git directory
    if [ -d .git ]; then
      # has a GitHub remote
      if git remote -v | grep -iq github; then
        echo
        echo "$(tput setaf 2)🟢 $dir$(tput sgr0)"
        gh pr list
        echo
      # does not have a GitHub remote
      else
        echo "$(tput setaf 214)🟠 $dir, not using GitHub$(tput sgr0)"
        cd ..
        continue
      fi
    # does not have a .git directory
    else
      echo "$(tput setaf 7)➖ $dir, not a git repo$(tput sgr0)"
    fi
    cd ..
  done
}


#######################################
# add signed & annontated semantic version tags(either single or floating tags) to a git repository
# Arguments:
#   $1 - major|minor|patch (required)
#   $2 - 'float' to add floating tags, null otherwise
#   $3 - 'push' the tags to the remote
# Outputs:
#   Writes the latest tag, the new tag, and the floating tags (if requested) to stdout
#######################################
function git-tag-semver() {
  if [[ $1 == "--help" || $1 == "-h" || $1 == "-?" ]]; then
    echo "Usage: git-tag-semver [ major | minor | patch ] [float] [push] [--help]"
    echo -e "Purpose: semantically tag a git repository"
    echo "Example 1: bump the patch version, no floating tags and no push"
    echo -e "  server> git-tag-semver patch\n"
    echo "Example 2: bump the minor version, with floating tags and no push"
    echo -e "  server> git-tag-semver minor float\n"
    echo "Example 3: bump the major version, without floating tags and push"
    echo -e "  server> git-tag-semver major null push\n"
  else
    git fetch --tags                             # Fetch tags from remote before calculating latest tag
    local latest_tag=$(git tag -l | grep -E '^v?([0-9]+\.){2}[0-9]+$' | sort -V | tail -n 1)
    latest_tag=${latest_tag:-0.0.0}              # Set default tag if no tags are found
    local prefix=''                              # Default to no prefix
    [[ $latest_tag == v* ]] && prefix='v'        # enable version prefix
    latest_tag=${latest_tag#v}                   # Remove 'v' prefix for version incrementing

    echo "Latest tag: $latest_tag"
    local major=$(echo $latest_tag | cut -d. -f1)
    local minor=$(echo $latest_tag | cut -d. -f2)
    local patch=$(echo $latest_tag | cut -d. -f3)
    case $1 in
      major)
        major=$((major + 1))
        minor=0
        patch=0
        ;;
      minor)
        minor=$((minor + 1))
        patch=0
        ;;
      patch)
        patch=$((patch + 1))
        ;;
      *)
        echo "Invalid argument: $1"
        return 1
        ;;
    esac
    major=${prefix}${major}                      # add v to major version if prefix is enabled
    echo "tagging version: $major.$minor.$patch"
    git rev-parse $major.$minor.$patch &>/dev/null && git tag -d $major.$minor.$patch
    git tag -sa $major.$minor.$patch -m "$major.$minor.$patch"

    # handle floating tags
    if [[ $2 == 'float' ]]; then
      echo "tagging version: $major.$minor"
      git rev-parse $major.$minor &>/dev/null && git tag -d $major.$minor
      git tag -sa $major.$minor -m "$major.$minor"

      echo "tagging version: $major"
      git rev-parse $major &>/dev/null && git tag -d $major
      git tag -sa $major -m "$major"
    fi

    if [[ $3 == 'push' ]]; then
      git push -f --tags
    fi
  fi
}


#######################################
# join two csv files on the first column. The first row of each file is assumed to be the header.
# Arguments:
#   $1 - 'file1' the first csv file
#   $2 - 'file2' the second csv file
# Outputs:
#   Writes the joined csv to stdout
#######################################
function joincsv () {
  if [[ $1 == "--help" || $1 == "-h" || $1 == "-?" ]]; then
    echo "Usage: joincsv [ file1 ] [ file2 ]"
    echo -e "Purpose: add data from the second csv as a new column in the first csv"
    echo "Example 1:"
    echo -e "  server> joincsv svrChkr-2015-08-27.csv OWNERS.csv\n"
  else
    join -t, -a1 --header --nocheck-order <(cat <(head -n1 "$1") <(sed 1d "$1" | sort) | sed 's/\r//') <(cat <(head -n1 "$2") <(sed 1d "$2"| sort) | sed 's/\r//')
  fi
}


#######################################
# log a shell command, its stdout, and stderr to a file
# Globals:
#   CMD_LOG_FILE - the file to log the command and its output to
# Arguments:
#   $* - the command to execute
# Outputs:
#   Writes the command and its output to the log file and stdout
#######################################
function log-cmd () {
    local header="####################################################\n"

    # check if log file has been named
    if [ -z "${CMD_LOG_FILE}" ]; then
      local CMD_LOG_FILE="/tmp/command.log"
      echo "No log file specified, using default: ${CMD_LOG_FILE}\n"
    fi

    {
      printf ${header}
      printf "\`%s\` executed at $(date '+%Y-%m-%d %H:%M:%S')\n" "$*"
      printf ${header}
      "$@"
      printf "\n"
    } 2>&1 | tee -a "${CMD_LOG_FILE}"
}


#######################################
# Pretty print a string with styles
# Arguments:
#   $1 - text to print (required)
#   $@ - styles to apply (optional)
# Outputs:
#   Writes the text to stdout with the styles applied
#######################################
function pprint() {
  local text="$1"
  shift
  local styles="$*"
  printf '%b%s%b\n' "${styles// /}" "$text" "$txReset"
}


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
