FROM mono:5.12

MAINTAINER Armando Basile <armando@integrazioneweb.com>

ENTRYPOINT ["/usr/bin/monodevelop"]

# setup proxy variables
ARG HTTP_PROXY
ARG HTTPS_PROXY

# Install Monodevelop
RUN \
    export http_proxy="$HTTP_PROXY" && \
    export https_proxy="$HTTPS_PROXY" && \
    apt-get update && \
    apt-get install -y monodevelop monodevelop-nunit mate-icon-theme-faenza lxappearance && \
    rm -rf /var/lib/apt/lists/*


# Install .NET CLI dependencies (WITH PROXY)
RUN \
    export http_proxy="$HTTP_PROXY" && \
    export https_proxy="$HTTPS_PROXY" && \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        libc6 \
        libcurl3 \
        libgcc1 \
        libgssapi-krb5-2 \
        libicu52 \
        liblttng-ust0 \
        libssl1.0.0 \
        libstdc++6 \
        libunwind8 \
        libuuid1 \
        zlib1g \
    && rm -rf /var/lib/apt/lists/*



# Install .NET Core SDK
ENV DOTNET_SDK_VERSION 2.1.202
ENV DOTNET_SDK_DOWNLOAD_URL https://dotnetcli.blob.core.windows.net/dotnet/Sdk/$DOTNET_SDK_VERSION/dotnet-sdk-$DOTNET_SDK_VERSION-linux-x64.tar.gz
ENV DOTNET_SDK_DOWNLOAD_SHA e785b9b488b5570708eb060f9a4cb5cf94597d99a8b0a3ee449d2e5df83771c1ba643a87db17ae6727d0e2acb401eca292fb8c68ad92eeb59d7f0d75eab1c20a

# Get .NET Code
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
    # Enable correct mode for dotnet watch (only mode supported in a container)
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    # Skip extraction of XML docs - generally not useful within an image/container - helps perfomance
    NUGET_XMLDOC_MODE=skip

# Trigger the population of the local package cache
RUN mkdir warmup \
    && cd warmup \
    && dotnet new \
    && cd .. \
    && rm -rf warmup \
    && rm -rf /tmp/NuGetScratch

# Workaround for https://github.com/Microsoft/DockerTools/issues/87. This instructs NuGet to use 4.5 behavior in which
# all errors when attempting to restore a project are ignored and treated as warnings instead. This allows the VS
# tooling to use -nowarn:MSB3202 to ignore issues with the .dcproj project
ENV RestoreUseSkipNonexistentTargets false
