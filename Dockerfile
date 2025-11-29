FROM ubuntu:20.04

ARG HTTP_PROXY=""
ARG HTTPS_PROXY=""

ENV http_proxy=$HTTP_PROXY
ENV https_proxy=$HTTPS_PROXY
ENV DEBIAN_FRONTEND=noninteractive

# Aggiungi repo Mono vs-bionic per MonoDevelop 7.8 su 20.04
RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-transport-https dirmngr gnupg ca-certificates curl software-properties-common && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
    echo "deb https://download.mono-project.com/repo/ubuntu vs-bionic main" | tee /etc/apt/sources.list.d/mono-official-vs.list && \
    # Aggiungi PPA per Papirus icon theme
    add-apt-repository ppa:papirus/papirus -y && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        mono-complete mono-xsp4 monodevelop mono-roslyn msbuild lxappearance papirus-icon-theme \
        libc6 libcurl4 libgcc1 libgssapi-krb5-2 libicu66 libssl1.1 libstdc++6 libunwind8 libuuid1 zlib1g && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

LABEL maintainer="armando-basile" \
      org.opencontainers.image.description="MonoDevelop Docker Image with latest Mono and Papirus icons" \
      org.opencontainers.image.version="7.8.4-1" \
      org.opencontainers.image.source="https://github.com/armando-basile/monodevelop-docker" \
      org.opencontainers.image.licenses="MIT"

EXPOSE 8080
ENTRYPOINT ["/usr/bin/monodevelop"]