# Dockerized Odoo Base Image

Image ready to put [Odoo](https://www.odoo.com) inside it, but **without
Odoo**.

## What?

Yes, this image has no Odoo inside, but is ready to put one inside, by using
all of its development and deployment facilities.

The purpose of this is to serve as a base for you to build your own Odoo
project, because most of them end up requiring a big amount of custom patches,
merges, repositories, etc. With this image, you have a collection of good
practices to enable your team to have a standard Odoo project structure.

## Image usage

Basically, every directory you have to worry about is found inside `/opt/odoo`.
This is its structure:

    auto
        addons/
        odoo.conf
    common/
        entrypoint.sh
        build.sh
        entrypoint.d/
        build.d/
        conf.d/
    custom/
        entrypoint.d/
        build.d/
        conf.d/
        src/
            private/
            odoo/
            addons.txt
            repos.yaml
