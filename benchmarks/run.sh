#!/bin/bash

printf "  $1"
coffee $1 &
pid=$!

sleep 1

wrk 'http://localhost:3333/' \
  -d 3 \
  -c 50 \
  -t 8 \
  | grep 'Requests/sec' \
  | awk '{ print " " $2 }'

kill $pid
