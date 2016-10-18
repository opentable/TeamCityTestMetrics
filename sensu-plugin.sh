#!/bin/sh

bail () {
  echo "$@"
  exit 3
}

dir=$(dirname $0)

test -z "$dir" && bail "call $0 with a path name"
cd "$dir" || bail "failed to cd to $dir"

environment=$(echo "$1" | tr '[:upper:]' '[:lower:]')

./main.rb $environment |
  while read line # sensu client api is not line oriented. :(
    do
      echo "$line" > /dev/udp/localhost/3030
    done
