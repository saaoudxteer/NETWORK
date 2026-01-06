#!/bin/bash

for d in VM*/; do
  echo "Starting $d"
  (cd "$d" && vagrant reload)
done
(base) 
