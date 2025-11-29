FROM debian:10

LABEL maintainer="armando-basile" \
      org.opencontainers.image.description="MonoDevelop 7.8.4 + Mono 6.12 + Xamarin-Dark theme" \
      org.opencontainers.image.version="7.8.4-3" \
      org.opencontainers.image.licenses="MIT"

ENTRYPOINT ["/usr/bin/monodevelop"]

EXPOSE 8080

# Proxy support
ARG HTTP_PROXY=""
ARG HTTPS_PROXY=""

# Use Debian archive repositories (Buster is EOL)
RUN echo "deb http://archive.debian.org/debian buster main contrib non-free" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security buster/updates main contrib non-free" >> /etc/apt/sources.list

# Install basic tools + ignore expired keys
RUN export http_proxy="$HTTP_PROXY" https_proxy="$HTTPS_PROXY" && \
    apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false && \
    apt-get install -y --allow-unauthenticated wget curl ca-certificates gnupg && \
    rm -rf /var/lib/apt/lists/*

# Add Mono official repository for Buster
RUN curl -s https://download.mono-project.com/repo/xamarin.gpg | apt-key add - && \
    echo "deb https://download.mono-project.com/repo/debian buster main" > /etc/apt/sources.list.d/mono-official.list

# Install MonoDevelop 7.8.4 + Mono 6.12 + GUI tools
RUN export http_proxy="$HTTP_PROXY" https_proxy="$HTTPS_PROXY" && \
    apt-get update -o Acquire::Check-Valid-Until=false && \
    apt-get install -y --allow-unauthenticated \
        monodevelop \
        monodevelop-nunit \
        monodevelop-versioncontrol \
        lxappearance \
        mono-xsp4 \
        gnome-terminal \
    && rm -rf /var/lib/apt/lists/*

# Fix gnome-terminal (needed for "Open Terminal" in MonoDevelop)
RUN mkdir -p /usr/lib/gnome-terminal && \
    ln -sf /usr/libexec/gnome-terminal-server /usr/lib/gnome-terminal/gnome-terminal-server

# Install Xamarin-Dark theme (exactly like your old working container)
RUN mkdir -p /root/.config/MonoDevelop/AddIns/MonoDevelop.UserInterfaceTheme/Xamarin-Dark && \
    cd /root/.config/MonoDevelop/AddIns/MonoDevelop.UserInterfaceTheme/Xamarin-Dark && \
    curl -O https://raw.githubusercontent.com/mono/guiunit/master/guiunit/MonoDevelop.GuiUnit/gtk-xamarin-dark/gtkrc && \
    curl -O https://raw.githubusercontent.com/mono/guiunit/master/guiunit/MonoDevelop.GuiUnit/gtk-xamarin-dark/gtk-widgets.css && \
    curl -O https://raw.githubusercontent.com/mono/guiunit/master/guiunit/MonoDevelop.GuiUnit/gtk-xamarin-dark/gtk-widgets-dark.css

# Optional: force dark theme at startup (you can remove if you want to choose manually)
RUN mkdir -p /root/.config/MonoDevelop && \
    echo '<?xml version="1.0" encoding="UTF-8"?><Properties><Property key="MonoDevelop.Ide.UserInterfaceTheme" value="Xamarin-Dark" /></Properties>' > /root/.config/MonoDevelop/Properties.xml

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["monodevelop"]