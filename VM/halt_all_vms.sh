#!/bin/bash

for d in VM*/; do
  echo "Halting process .. $d"
  (cd "$d" && vagrant halt)
done
