#Stage 1: Build stage non necessario, usiamo apt per install
FROM ubuntu:20.04

ARG HTTP_PROXY=""
ARG HTTPS_PROXY=""

ENV http_proxy=$HTTP_PROXY
ENV https_proxy=$HTTPS_PROXY
ENV DEBIAN_FRONTEND=noninteractive

# Aggiungi repo Mono official (preview per versione più recente)
RUN apt-get update && \
    apt-get install -y --no-install-recommends gnupg ca-certificates curl && \
    curl -fsSL https://download.mono-project.com/repo/xamarin.gpg | gpg --dearmor -o /usr/share/keyrings/mono-official-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/mono-official-archive-keyring.gpg] https://download.mono-project.com/repo/ubuntu preview-focal main" > /etc/apt/sources.list.d/mono-official-preview.list && \
    echo "deb [signed-by=/usr/share/keyrings/mono-official-archive-keyring.gpg] https://download.mono-project.com/repo/ubuntu stable-focal main" > /etc/apt/sources.list.d/mono-official-stable.list && \
    # Aggiungi PPA per Papirus icon theme
    apt-get update && apt-get install -y --no-install-recommends software-properties-common && \
    add-apt-repository ppa:papirus/papirus -y && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        mono-complete mono-xsp4 monodevelop mono-roslyn msbuild lxappearance papirus-icon-theme \
        libc6 libcurl4 libgcc1 libgssapi-krb5-2 libicu66 libssl1.1 libstdc++6 libunwind8 libuuid1 zlib1g && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

LABEL maintainer="armando-basile" \
      org.opencontainers.image.description="MonoDevelop Docker Image with latest Mono and Papirus icons" \
      org.opencontainers.image.version="7.8.4.1-1" \
      org.opencontainers.image.source="https://github.com/armando-basile/monodevelop-docker" \
      org.opencontainers.image.licenses="MIT"

EXPOSE 8080
ENTRYPOINT ["/usr/bin/monodevelop"]