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
