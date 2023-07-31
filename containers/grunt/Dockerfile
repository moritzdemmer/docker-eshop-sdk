ARG CONTAINER_GID=1000
ARG CONTAINER_UID=1000
ARG CONTAINER_USER=handBookNotRead

USER ${CONTAINER_UID}:${CONTAINER_GID}

FROM node:8

RUN apt-get update \
    && apt-get install -y \
    git \
    curl \
    gnupg \
    make \
    ruby \
    ruby-sass \
    fontforge ttfautohint \
    && npm install -g grunt-cli


