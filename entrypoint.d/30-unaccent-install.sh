#!/bin/sh
if [ "$UNACCENT" == yes ]; then
    echo Trying to install unaccent in $PGDATABASE@$PGHOST... > /dev/stderr
    psql --command 'CREATE EXTENSION IF NOT EXISTS unaccent;'
fi
