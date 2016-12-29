#!/bin/sh
set -ex

# Generate Odoo server configuration from templates
cat /opt/odoo/common/conf.d/* /opt/odoo/custom/conf.d/* | \
    envsubst > /opt/odoo/auto/odoo.conf
