# Stage 1: Build MonoDevelop from source
FROM ubuntu:20.04 AS builder

ARG HTTP_PROXY=""
ARG HTTPS_PROXY=""

ENV http_proxy=$HTTP_PROXY
ENV https_proxy=$HTTPS_PROXY
ENV DEBIAN_FRONTEND=noninteractive

# Installa dipendenze per build MonoDevelop e Mono
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gnupg ca-certificates wget tar bzip2 git automake libtool intltool make g++ cmake libssh2-1-dev \
        mono-complete gtk-sharp2 fsharp && \
    rm -rf /var/lib/apt/lists/*

# Download e build MonoDevelop 7.8.4.1 da source
RUN wget https://download.mono-project.com/sources/monodevelop/monodevelop-7.8.4.1.tar.bz2 && \
    tar xjf monodevelop-7.8.4.1.tar.bz2 && \
    cd monodevelop-7.8.4.1 && \
    ./configure --prefix=/usr && \
    make && \
    make install && \
    cd .. && \
    rm -rf monodevelop-7.8.4.1 monodevelop-7.8.4.1.tar.bz2

# Stage 2: Runtime image ottimizzata
FROM ubuntu:20.04

ARG HTTP_PROXY=""
ARG HTTPS_PROXY=""

ENV http_proxy=$HTTP_PROXY
ENV https_proxy=$HTTPS_PROXY
ENV DEBIAN_FRONTEND=noninteractive

# Installa runtime essenziali: Mono, XSP4, temi, etc.
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget gnupg ca-certificates curl && \
    # Aggiungi repo Mono ufficiale per latest Mono
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
    echo "deb https://download.mono-project.com/repo/ubuntu stable-focal main" > /etc/apt/sources.list.d/mono-official-stable.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        mono-complete mono-xsp4 webkit-sharp mate-icon-theme-faenza lxappearance \
        libc6 libcurl4 libgcc1 libgssapi-krb5-2 libicu66 libssl1.1 libstdc++6 libunwind8 libuuid1 zlib1g && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copia MonoDevelop built dallo stage builder
COPY --from=builder /usr/lib/monodevelop /usr/lib/monodevelop
COPY --from=builder /usr/bin/monodevelop /usr/bin/monodevelop
COPY --from=builder /usr/share/monodevelop /usr/share/monodevelop

EXPOSE 8080
ENTRYPOINT ["/usr/bin/monodevelop"]