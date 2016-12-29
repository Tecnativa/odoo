FROM python:2-alpine
MAINTAINER Tecnativa <info@tecnativa.com>

VOLUME ["/home/odoo/.local/share/Odoo"]
EXPOSE 8069 8072
ENTRYPOINT ["/opt/odoo/common/entrypoint.sh"]
CMD ["/opt/odoo/custom/src/odoo/odoo.py"]

ARG CLEAN=no
ARG COMPILE=yes

ENV ODOO_VERSION=9.0 \
    ODOO_SOURCE=OCA/OCB \
    ODOO_RC=/opt/odoo/auto/odoo.conf \
    ADMIN_PASSWORD=admin \
    PROXY_MODE=yes \
    SMTP_SERVER=smtp \
    UNACCENT=yes \
    # Git and git-aggregator
    GIT_AUTHOR_NAME=docker-odoo \
    EMAIL=https://hub.docker.com/r/tecnativa/odoo \
    # Postgres
    PGUSER=odoo \
    PGPASSWORD=odoopassword \
    PGHOST=db \
    PGDATABASE=odooproduction \
    # WDB debugger
    WDB_NO_BROWSER_AUTO_OPEN=True \
    WDB_SOCKET_SERVER=wdb \
    WDB_WEB_PORT=1984 \
    WDB_WEB_SERVER=localhost

# Requirements to build Odoo dependencies
RUN apk add --no-cache --virtual .temp-deps \
    # Common to all Python packages
    build-base python-dev \
    # lxml
    libxml2-dev libxslt-dev \
    # Pillow
    jpeg-dev zlib-dev freetype-dev lcms2-dev openjpeg-dev \
    tiff-dev tk-dev tcl-dev \
    # psutil
    linux-headers \
    # psycopg2
    postgresql-dev \
    # python-ldap
    openldap-dev \

    # Build and install Odoo dependencies with pip
    && pip install --no-cache-dir --requirement https://raw.githubusercontent.com/$ODOO_SOURCE/$ODOO_VERSION/requirements.txt \

    # Remove all installed garbage
    && apk del .temp-deps \

    # Enable Odoo user and link its future binary location
    && adduser -D odoo \
    && ln -s /opt/odoo/custom/src/odoo/odoo.py /usr/local/bin/

# Special case for wkhtmltox
# HACK https://github.com/wkhtmltopdf/wkhtmltopdf/issues/3265
# Idea from https://hub.docker.com/r/loicmahieu/alpine-wkhtmltopdf/
# Use prepackaged wkhtmltopdf and wrap it with a dummy X server
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing wkhtmltopdf
RUN apk add --no-cache xvfb ttf-freefont fontconfig dbus
COPY wkhtmltox.sh /usr/local/bin/wkhtmltoimage
RUN ln /usr/local/bin/wkhtmltoimage /usr/local/bin/wkhtmltopdf

# Patched git-aggregator
RUN pip install --no-cache-dir https://github.com/Tecnativa/git-aggregator/archive/master.zip
# HACK Install git >= 2.11, to have --shallow-since
# TODO Remove HACK when python:2-alpine is alpine >= v3.5
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.5/main git

# WDB debugger
RUN pip install --no-cache-dir wdb

# Other facilities
COPY unittest.sh /usr/local/bin/
COPY direxec.sh /opt/odoo/common/entrypoint.sh
COPY build.d conf.d entrypoint.d /opt/odoo/common/
RUN ln /opt/odoo/common/entrypoint.sh /opt/odoo/common/build.sh \
    && apk add --no-cache postgresql-client \
    && chmod -R a+rx /opt/odoo/common
ONBUILD COPY . /opt/odoo/custom
ONBUILD RUN ["/opt/odoo/common/build.sh"]
USER odoo
