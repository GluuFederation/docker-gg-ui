FROM mhart/alpine-node:6.11.3 

# ==================
# Metadata
# ==================

LABEL name="gluu-gateway-ui" \
    maintainer="Gluu Inc. <support@gluu.org>" \
    vendor="Gluu Federation" \
    version="4.0.0" \
    release="dev" \
    summary="Gluu gateway UI " \
    description="Gluu Gateway Admistrative User interface"

WORKDIR /app

RUN apk update && apk upgrade \
    && apk add --no-cache --update subversion bash git ca-certificates openssl \
    && npm install -g bower \
    && npm --unsafe-perm --production install

# ====
# ENV
# ===

# Gluu Gateway
ENV GLUU_VERSION=v4.0.0

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
    GG_VERSION=4.1 \
    EXPLICIT_HOST=0.0.0.0

# https://github.com/GluuFederation/gluu-gateway.git
RUN svn ls https://github.com/GluuFederation/gluu-gateway.git/branches/version_4.1/konga 
    # && unzip -q ./konga.zip -d ./ \
    # && mv ./kong/* . \
    # && rm -rf ./konga.zip ./gluu-gateway-version_4.1

RUN ls ./

EXPOSE 1337

COPY /scripts/entrypoint.sh /app 

RUN chmod +x entrypoint.sh

ENTRYPOINT [ "/bin/bash", "./entrypoint.sh" ]

