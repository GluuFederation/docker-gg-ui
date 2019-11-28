FROM node:10-alpine

RUN apk update \
    && apk add --no-cache --virtual build-deps subversion git

# ===============
# Gluu Gateway UI
# ===============

ENV GLUU_VERSION=v4.0.0

RUN svn co https://github.com/GluuFederation/gluu-gateway/tags/${GLUU_VERSION}/konga /opt/gluu-gateway/konga \
    && cd /opt/gluu-gateway/konga \
    && npm install -g bower \
    && npm --unsafe-perm --production install \
    && rm -rf .svn screenshots test Dockerfile .dockerignore .gitignore

# =======
# Cleanup
# =======

RUN apk del build-deps \
    && rm -rf /var/cache/apk/*

# ================
# Environment vars
# ================

# for DB connections
ENV DB_HOST=localhost \
    DB_USER=postgres \
    DB_PASSWORD=admin \
    DB_PORT=5432 \
    DB_DATABASE=konga \
    DB_POOLSIZE=10 \
    DB_SSL=false \
    DB_ADAPTER=postgres \
    POSTGRES_VERSION=10.x \
    HOOK_TIMEOUT=180000 \ 
    PORT=1338 
#session
ENV SESSION_SECRET=pass_your_own_secret

# certs
ENV SSL_KEY_PATH=key.pem \
    SSL_CERT_PATH=cert.pem 

# OXD variables
ENV OXD_SERVER_URL=https://localhost:8553 \
    OP_SERVER_URL=https://demoexample.gluu.org \
    OXD_ID=0cc5503c-6cce-4ba4-b6d7-0786b6d2dxxx \
    CLIENT_ID=xxx03c-6cce-4ba4-b6d7-0786b6d2dxxx \
    CLIENT_SECRET=a5263b14-0afb-4a59-b42a-81d656e8717c \
    OXD_SERVER_VERSION=4.0 \
    GG_VERSION=4.0 \
    EXPLICIT_HOST=0.0.0.0

# ===========
# Metadata
# ===========

LABEL name="gluu-gateway-ui" \
    maintainer="Gluu Inc. <support@gluu.org>" \
    vendor="Gluu Federation" \
    version="4.0.0" \
    release="dev" \
    summary="Gluu Gateway UI" \
    description="Gluu Gateway (GG) is an API gateway that leverages the Gluu Server for central OAuth client management and access control"

# ====
# misc
# ====

COPY scripts/start.sh /opt/gluu-gateway/konga/start.sh
RUN chmod +x /opt/gluu-gateway/konga/start.sh

EXPOSE 1337

WORKDIR /opt/gluu-gateway/konga
ENTRYPOINT ["/opt/gluu-gateway/konga/start.sh"]
