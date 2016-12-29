#!/bin/sh
echo Waiting until postgres is listening at $PGHOST... > /dev/stderr
while true; do
    psql --list > /dev/null 2>&1 && break
    sleep 1
done
