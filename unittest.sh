#!/bin/sh
# Shortcut to run Odoo in unit testing mode
# HACK https://github.com/odoo/odoo/pull/14809
exec odoo.py --init $1 --update $1 --log-level debug --workers 0 ${@:1}
