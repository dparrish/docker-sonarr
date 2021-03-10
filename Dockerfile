FROM ghcr.io/linuxserver/baseimage-mono:focal

# set version label
ARG BUILD_DATE
ARG VERSION
ARG SONARR_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

# set environment variables
ARG DEBIAN_FRONTEND="noninteractive"
ENV XDG_CONFIG_HOME="/config/xdg"
ENV SONARR_BRANCH="develop"

RUN \
 echo "**** install packages ****" && \
 apt-get update && \
 apt-get install -y \
    jq \
    libmediainfo0v5 && \
 echo "**** install sonarr ****" && \
 mkdir -p /app/sonarr/bin && \
    if [ -z ${SONARR_VERSION+x} ]; then \
        SONARR_VERSION=$(curl -sX GET http://services.sonarr.tv/v1/releases \
        | jq -r ".[] | select(.branch==\"$SONARR_BRANCH\") | .version"); \
    fi && \
 curl -o \
    /tmp/sonarr.tar.gz -L \
    "https://download.sonarr.tv/v3/${SONARR_BRANCH}/${SONARR_VERSION}/Sonarr.${SONARR_BRANCH}.${SONARR_VERSION}.linux.tar.gz" && \
 tar xf \
    /tmp/sonarr.tar.gz -C \
    /app/sonarr/bin --strip-components=1 && \
 echo "**** cleanup ****" && \
 apt-get clean && \
 rm -rf \
    /tmp/* \
    /var/tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8989
VOLUME /config
