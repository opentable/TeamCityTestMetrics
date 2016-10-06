#!/bin/sh

bail () {
  echo "$@"
  exit 3
}

dir=$(dirname $0)

test -z "$dir" && bail "call $0 with a path name"
cd "$dir" || bail "failed to cd to $dir"

exec ./main.rb > /dev/tcp/localhost/3030
