FROM ubuntu:20.04

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

# Remove updates/backports/security to avoid version conflicts
RUN sed -i '/focal-updates/d' /etc/apt/sources.list && \
    sed -i '/focal-backports/d' /etc/apt/sources.list && \
    sed -i '/focal-security/d' /etc/apt/sources.list

# Install dependencies and tools
RUN \
    export http_proxy="$HTTP_PROXY" && \
    export https_proxy="$HTTPS_PROXY" && \
    apt-get update && \
    apt-get install -y wget gnupg ca-certificates curl && \
    rm -rf /var/lib/apt/lists/*

# Install libjpeg62-turbo from NVIDIA mirror
RUN \
    export http_proxy="$HTTP_PROXY" && \
    export https_proxy="$HTTPS_PROXY" && \
    wget https://download.nvidia.com/cumulus/apt.cumulusnetworks.com/pool/upstream/libj/libjpeg-turbo/libjpeg62-turbo_1.5.2-2+deb10u1_amd64.deb && \
    dpkg -i libjpeg62-turbo_1.5.2-2+deb10u1_amd64.deb && \
    rm libjpeg62-turbo_1.5.2-2+deb10u1_amd64.deb

# Add Mono preview repository with signed-by (for MonoDevelop)
RUN \
    export http_proxy="$HTTP_PROXY" && \
    export https_proxy="$HTTPS_PROXY" && \
    wget -O /tmp/xamarin.gpg https://download.mono-project.com/repo/xamarin.gpg && \
    gpg --homedir /tmp --no-default-keyring --keyring /usr/share/keyrings/mono-official-archive.gpg --import /tmp/xamarin.gpg && \
    rm /tmp/xamarin.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/mono-official-archive.gpg] https://download.mono-project.com/repo/ubuntu preview-focal main" > /etc/apt/sources.list.d/mono-official-preview.list

# Install MonoDevelop and related packages
RUN \
    export http_proxy="$HTTP_PROXY" && \
    export https_proxy="$HTTPS_PROXY" && \
    apt-get update && \
    apt-get install -y monodevelop monodevelop-nunit monodevelop-versioncontrol \
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
    apt-get update \
    && apt-get install -y --no-install-recommends \
        libc6 \
        libcurl4 \
        libgcc1 \
        libgssapi-krb5-2 \
        libicu66 \
        liblttng-ust0 \
        libssl1.1 \
        libstdc++6 \
        libunwind8 \
        libuuid1 \
        zlib1g \
    && rm -rf /var/lib/apt/lists/*

# Install .NET Core SDK (updated to compatible version)
ENV DOTNET_SDK_VERSION 6.0.427
ENV DOTNET_SDK_DOWNLOAD_URL https://dotnetcli.azureedge.net/dotnet/Sdk/$DOTNET_SDK_VERSION/dotnet-sdk-$DOTNET_SDK_VERSION-linux-x64.tar.gz
RUN \
    export http_proxy="$HTTP_PROXY" && \
    export https_proxy="$HTTPS_PROXY" && \
    curl -SL $DOTNET_SDK_DOWNLOAD_URL --output dotnet.tar.gz \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf dotnet.tar.gz -C /usr/share/dotnet \
    && rm dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

# Enable detection of running in a container
ENV DOTNET_RUNNING_IN_CONTAINER=true
ENV DOTNET_USE_POLLING_FILE_WATCHER=true
ENV NUGET_XMLDOC_MODE=skip

# Trigger the population of the local package cache
RUN mkdir warmup \
    && cd warmup \
    && dotnet new \
    && cd .. \
    && rm -rf warmup \
    && rm -rf /tmp/NuGetScratch

ENV RestoreUseSkipNonexistentTargets false