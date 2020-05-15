FROM node:10-alpine AS build

RUN apk add --update --no-cache --virtual \
    build-deps \
    git

ENV GLUU_GATEWAY_UI_VERSION=version_4.2.0

RUN git clone --single-branch --branch ${GLUU_GATEWAY_UI_VERSION} https://github.com/GluuFederation/gluu-gateway-ui.git /gg-tmp \
    && cd /gg-tmp \
    && npm install -g bower \
    && npm --unsafe-perm --production install \
    && npm update -g \
    && rm -rf .svn screenshots test .dockerignore .gitignore 

# ==========================
# Gluu Gateway UI Main Image
# ==========================

FROM node:10-alpine

WORKDIR /opt/gluu-gateway-ui

COPY --from=build /gg-tmp /opt/gluu-gateway-ui 

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
    KONGA_HOOK_TIMEOUT=180000 \
    PORT=1338 \
    KONG_ADMIN_URL=http://localhost:8001
#session
ENV SESSION_SECRET=""

# certs
ENV SSL_KEY_PATH=/etc/certs/key.pem \
    SSL_CERT_PATH=/etc/certs/certificate.pem

# OXD variables
ENV OXD_SERVER_URL=https://localhost:8553 \
    OP_SERVER_URL=https://demoexample.gluu.org \
    OXD_ID="" \
    CLIENT_ID="" \
    CLIENT_SECRET="" \
    OXD_SERVER_VERSION=4.2 \
    GG_VERSION=4.2 \
    EXPLICIT_HOST=127.0.0.1 \
    GG_UI_REDIRECT_URL_HOST=localhost \
    GG_HOST=localhost

# ===========
# Metadata
# ===========

LABEL name="gluu-gateway-ui" \
    maintainer="Gluu Inc. <support@gluu.org>" \
    vendor="Gluu Federation" \
    version="4.2.0" \
    release="dev" \
    summary="Gluu Gateway UI" \
    description="User Interface (UI) for Gluu Gateway"

# ====
# misc
# ====

# COPY /scripts/entrypoint.sh /opt/gluu-gateway-ui/setup/entrypoint.sh
RUN chmod +x ./entrypoint.sh

EXPOSE 1337

ENTRYPOINT ["/bin/sh", "./entrypoint.sh"]
