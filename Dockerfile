FROM mhart/alpine-node:6.11.3

RUN apk update \
    && apk add --no-cache --virtual build-deps git

# ===============
# Gluu Gateway UI
# ===============

ENV GIT_BRANCH=version_4.1

WORKDIR /opt/gluu-gateway-ui

RUN git clone --single-branch --branch ${GIT_BRANCH} https://github.com/GluuFederation/gluu-gateway-ui.git /opt/gluu-gateway-ui \
    && cd /opt/gluu-gateway-ui \
    && npm install -g bower \
    && npm --unsafe-perm --production install \
    && rm -rf .svn screenshots test Dockerfile .dockerignore .gitignore start.sh

# =======
# Cleanup
# =======

RUN apk del build-deps \
    && rm -rf /var/cache/apk/*

# ================
# Environment vars
# ================

# for DB connections
ENV DB_HOST=kong-database \
    DB_USER=konga \
    DB_PASSWORD=konga \
    DB_PORT=5432 \
    DB_DATABASE=konga \
    DB_POOLSIZE=10 \
    DB_SSL=false \
    DB_ADAPTER=postgres \
    POSTGRES_VERSION=10.x \
    HOOK_TIMEOUT=180000 \
    PORT=1338
#session
ENV SESSION_SECRET=

# certs
ENV SSL_KEY_PATH=/etc/certs/key.pem \
    SSL_CERT_PATH=/etc/certs/certificate.pem

# OXD variables
ENV OXD_SERVER_URL=https://localhost:8553 \
    OP_SERVER_URL=https://demoexample.gluu.org \
    OXD_ID= \
    CLIENT_ID= \
    CLIENT_SECRET= \
    OXD_SERVER_VERSION=4.0 \
    GG_VERSION=4.0 \
    EXPLICIT_HOST=0.0.0.0

# ===========
# Metadata
# ===========

LABEL name="gluu-gateway-ui" \
    maintainer="Gluu Inc. <support@gluu.org>" \
    vendor="Gluu Federation" \
    version="4.1.0" \
    release="dev" \
    summary="Gluu Gateway UI" \
    description="User Interface (UI) for Gluu Gateway"

# ====
# misc
# ====

COPY /scripts/start.sh /opt/gluu-gateway-ui/setup/start.sh
RUN chmod +x /opt/gluu-gateway-ui/setup/start.sh 

EXPOSE 1337

ENTRYPOINT ["/bin/sh", "/opt/gluu-gateway-ui/setup/start.sh"]
