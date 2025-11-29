FROM debian:10

LABEL maintainer="armando-basile" \
      org.opencontainers.image.description="MonoDevelop Docker Image with latest Mono and Papirus icons" \
      org.opencontainers.image.version="7.8.4-2" \
      org.opencontainers.image.source="https://github.com/armando-basile/monodevelop-docker" \
      org.opencontainers.image.licenses="MIT"

ENTRYPOINT ["/usr/bin/monodevelop"]

EXPOSE 8080

# setup proxy variables
ARG HTTP_PROXY=""
ARG HTTPS_PROXY=""

# Update sources to archive for Buster EOL
RUN echo "deb http://archive.debian.org/debian buster main contrib non-free" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security buster/updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian buster-updates main contrib non-free" >> /etc/apt/sources.list && \
    apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false

# Install dependencies and tools
RUN \
    export http_proxy="$HTTP_PROXY" && \
    export https_proxy="$HTTPS_PROXY" && \
    apt-get install -y --allow-unauthenticated wget gnupg ca-certificates curl dpkg && \
    rm -rf /var/lib/apt/lists/*

# Install libjpeg62-turbo from archive
RUN \
    export http_proxy="$HTTP_PROXY" && \
    export https_proxy="$HTTPS_PROXY" && \
    wget http://archive.debian.org/debian/pool/main/libj/libjpeg-turbo/libjpeg62-turbo_1.5.2-2+deb10u1_amd64.deb && \
    dpkg -i libjpeg62-turbo_1.5.2-2+deb10u1_amd64.deb && \
    rm libjpeg62-turbo_1.5.2-2+deb10u1_amd64.deb

# Add Mono Buster repository
RUN \
    export http_proxy="$HTTP_PROXY" && \
    export https_proxy="$HTTPS_PROXY" && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
    echo "deb https://download.mono-project.com/repo/debian buster main" > /etc/apt/sources.list.d/mono-official-vs.list

# Install MonoDevelop and related packages
RUN \
    export http_proxy="$HTTP_PROXY" && \
    export https_proxy="$HTTPS_PROXY" && \
    apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false && \
    apt-get install -y --allow-unauthenticated monodevelop monodevelop-nunit monodevelop-versioncontrol \
        lxappearance mono-xsp4 gnome-terminal && \
    rm -rf /var/lib/apt/lists/*

# Fix gnome-terminal for debugging
RUN mkdir -p /usr/lib/gnome-terminal && ln -s /usr/libexec/gnome-terminal-server /usr/lib/gnome-terminal/

# Install Xamarin-Dark theme files
RUN mkdir -p /root/.config/MonoDevelop/AddIns/MonoDevelop.UserInterfaceTheme/Xamarin-Dark \
    && cd /root/.config/MonoDevelop/AddIns/MonoDevelop.UserInterfaceTheme/Xamarin-Dark \
    && curl -O https://raw.githubusercontent.com/mono/guiunit/master/guiunit/MonoDevelop.GuiUnit/gtk-xamarin-dark/gtkrc \
    && curl -O https://raw.githubusercontent.com/mono/guiunit/master/guiunit/MonoDevelop.GuiUnit/gtk-xamarin-dark/gtk-widgets.css \
    && curl -O https://raw.githubusercontent.com/mono/guiunit/master/guiunit/MonoDevelop.GuiUnit/gtk-xamarin-dark/gtk-widgets-dark.css

# Install .NET CLI dependencies (WITH PROXY)
RUN \
    export http_proxy="$HTTP_PROXY" && \
    export https_proxy="$HTTPS_PROXY" && \
    apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false && \
    apt-get install -y --allow-unauthenticated --no-install-recommends \
        libc6 \
        libcurl4 \
        libgcc1 \
        libgssapi-krb5-2 \
        libicu63 \
        liblttng-ust0 \
        libssl1.1 \
        libstdc++6 \
        libunwind8 \
        libuuid1 \
        zlib1g \
    && rm -rf /var/lib/apt/lists/*

# Install .NET Core SDK (original version 2.1 for compatibility)
ENV DOTNET_SDK_VERSION 2.1.202
ENV DOTNET_SDK_DOWNLOAD_URL https://dotnetcli.blob.core.windows.net/dotnet/Sdk/$DOTNET_SDK_VERSION/dotnet-sdk-$DOTNET_SDK_VERSION-linux-x64.tar.gz
ENV DOTNET_SDK_DOWNLOAD_SHA e785b9b488b5570708eb060f9a4cb5cf94597d99a8b0a3ee449d2e5df83771c1ba643a87db17ae6727d0e2acb401eca292fb8c68ad92eeb59d7f0d75eab1c20a
RUN \
    export http_proxy="$HTTP_PROXY" && \
    export https_proxy="$HTTPS_PROXY" && \
    curl --insecure -SL $DOTNET_SDK_DOWNLOAD_URL --output dotnet.tar.gz \
    && echo "$DOTNET_SDK_DOWNLOAD_SHA dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf dotnet.tar.gz -C /usr/share/dotnet \
    && rm dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

# Enable detection of running in a container
ENV DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    NUGET_XMLDOC_MODE=skip

# Trigger the population of the local package cache
RUN mkdir warmup \
    && cd warmup \
    && dotnet new \
    && cd .. \
    && rm -rf warmup \
    && rm -rf /tmp/NuGetScratch

ENV RestoreUseSkipNonexistentTargets=false