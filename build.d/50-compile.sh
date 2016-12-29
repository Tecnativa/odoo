#!/bin/sh
set -ex

# Compile all code in repos if build requires so
if [ "$COMPILE" == yes ]; then
    python -m compileall /opt/odoo/custom/src
fi
