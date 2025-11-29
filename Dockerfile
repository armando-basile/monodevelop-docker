# Stage 1: Build MonoDevelop from source
FROM ubuntu:20.04 AS builder

ARG HTTP_PROXY=""
ARG HTTPS_PROXY=""

ENV http_proxy=$HTTP_PROXY
ENV https_proxy=$HTTPS_PROXY
ENV DEBIAN_FRONTEND=noninteractive

# Installa dipendenze base e aggiungi repo Mono per latest Mono durante build
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gnupg ca-certificates wget curl tar bzip2 git automake libtool intltool make g++ cmake libssh2-1-dev \
        autoconf zlib1g-dev libglade2-dev && \
    curl -fsSL https://download.mono-project.com/repo/xamarin.gpg | gpg --dearmor -o /usr/share/keyrings/mono-official-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/mono-official-archive-keyring.gpg] https://download.mono-project.com/repo/ubuntu stable-focal main" > /etc/apt/sources.list.d/mono-official-stable.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        mono-complete gtk-sharp2 fsharp monodoc-base && \
    rm -rf /var/lib/apt/lists/*

# Clone repo Git, checkout tag 7.8.4.1, fix submodule URLs to https, update submodules, e build
RUN git clone https://github.com/mono/monodevelop.git && \
    cd monodevelop && \
    git checkout monodevelop-7.8.4.1 && \
    sed -i 's|git://github.com|https://github.com|g' .gitmodules && \
    git submodule update --init --recursive && \
    ./configure --prefix=/usr && \
    make && \
    make install && \
    cd .. && \
    rm -rf monodevelop

# Stage 2: Runtime image ottimizzata
FROM ubuntu:20.04

LABEL maintainer="armando-basile" \
      org.opencontainers.image.description="MonoDevelop Docker Image with latest Mono and Papirus icons" \
      org.opencontainers.image.version="7.8.4.1" \
      org.opencontainers.image.source="https://github.com/armando-basile/monodevelop-docker" \
      org.opencontainers.image.licenses="MIT"

ARG HTTP_PROXY=""
ARG HTTPS_PROXY=""

ENV http_proxy=$HTTP_PROXY
ENV https_proxy=$HTTPS_PROXY
ENV DEBIAN_FRONTEND=noninteractive

# Installa runtime essenziali: Mono, XSP4, temi, etc.
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget gnupg ca-certificates curl software-properties-common && \
    # Aggiungi repo Mono ufficiale per latest Mono con metodo sicuro (no keyserver)
    curl -fsSL https://download.mono-project.com/repo/xamarin.gpg | gpg --dearmor -o /usr/share/keyrings/mono-official-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/mono-official-archive-keyring.gpg] https://download.mono-project.com/repo/ubuntu stable-focal main" > /etc/apt/sources.list.d/mono-official-stable.list && \
    # Aggiungi PPA per Papirus icon theme
    add-apt-repository ppa:papirus/papirus -y && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        mono-complete mono-xsp4 lxappearance papirus-icon-theme \
        libc6 libcurl4 libgcc1 libgssapi-krb5-2 libicu66 libssl1.1 libstdc++6 libunwind8 libuuid1 zlib1g && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copia MonoDevelop built dallo stage builder
COPY --from=builder /usr/lib/monodevelop /usr/lib/monodevelop
COPY --from=builder /usr/bin/monodevelop /usr/bin/monodevelop
COPY --from=builder /usr/share/monodevelop /usr/share/monodevelop

EXPOSE 8080
ENTRYPOINT ["/usr/bin/monodevelop"]