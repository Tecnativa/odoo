#!/bin/sh
set -ex

# Check if the `addons.txt` file is provided
list=/opt/odoo/custom/addons.txt
if [ -f $list ]; then
    # Autocreate the addons directory
    dir=/opt/odoo/auto/addons
    mkdir -p $dir
    cd $dir
    # Link each addon found in `addons.txt`
    for addon in $(cat $list); do
        ln -sf /opt/odoo/custom/src/$addon .
    done
fi
