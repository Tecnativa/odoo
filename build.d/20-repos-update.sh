#!/bin/sh
set -ex

# Update linked repositories, if the `repos.yaml` file is found
if [ -f /opt/odoo/custom/repos.yaml ]; then
    gitaggregate -c /opt/odoo/custom/src/repos.yaml
fi
