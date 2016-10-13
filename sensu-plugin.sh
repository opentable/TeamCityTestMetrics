#!/bin/sh

bail () {
  echo "$@"
  exit 3
}

dir=$(dirname $0)

test -z "$dir" && bail "call $0 with a path name"
cd "$dir" || bail "failed to cd to $dir"

environment=$(echo "$1" | tr '[:upper:]' '[:lower:]')

exec ./main.rb $environment > /dev/tcp/localhost/3030
