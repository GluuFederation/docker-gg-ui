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

WORKDIR /opt/gluu-gateway/konga
ENTRYPOINT ["/opt/gluu-gateway/konga/start.sh"]
