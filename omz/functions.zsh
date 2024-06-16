# functions

joincsv () {
  if test @$1 = @--help -o @$1 = @-h -o @$1 = @-?; then
    echo "Usage: joincsv [ file1 ] [ file2 ]"
    echo -e "Purpose: add data from the second csv as a new column in the first csv"
    echo "Example 1:"
    echo -e "  server> joincsv svrChkr-2015-08-27.csv OWNERS.csv\n"
  else
    join -t, -a1 --header --nocheck-order <(cat <(head -n1 "$1") <(sed 1d "$1" | sort) | sed 's/\r//') <(cat <(head -n1 "$2") <(sed 1d "$2"| sort) | sed 's/\r//')
  fi
}

getsudohash() {
  if test @$1 = @--help -o @$1 = @-h -o @$1 = @-?; then
    echo "Usage: getsudohash [ hostname ]"
    echo -e "Purpose: ssh to server and report hash"
    echo "Example 1:"
    echo -e "  server> getsudohash SOME_SERVER\n"
  else
    ssh ${1} 'sha1sum <(sudo cat $(sudo find /etc/sudoers.d -type f -print | sort) /etc/sudoers) | colrm 41 | sed "s/^/$(hostname)\t/"'
  fi
}

update_forge_modules () {
  for dir in $(ls -1); do
    echo $dir
    git -C "$dir" fetch -p origin
    git -C "$dir" push --mirror
    echo
    echo
  done
}

# function to semantically tag a git repository, optionally with floating tags
# usage: git-tag-semver <major|minor|patch> [float] [push] [--help]
git-tag-semver() {
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
