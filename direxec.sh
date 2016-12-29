#!/bin/sh
# Thanks Camptocamp for the idea!
# http://www.camptocamp.com/en/actualite/flexible-docker-entrypoints-scripts/
set -ex

mode=$(basename $0 .sh)

for dir in common custom; do
    dir=/opt/odoo/$dir/$mode.d
    if [ -d $dir ]; then
        run-parts --exit-on-error $dir
    fi
done

if [ -n "$@" ]; then
    exec "$@"
fi
