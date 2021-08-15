#!/bin/bash

set -x

while true; do
  clear
  MIX_ENV=test mix test "$@"
  inotifywait -qre close_write,create,delete,move --exclude '^.git|^./.git/' .
done
