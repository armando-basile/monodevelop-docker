FROM mono:5.12

MAINTAINER Armando Basile <armando@integrazioneweb.com>

ENTRYPOINT ["/usr/bin/monodevelop"]

# with proxy use
# RUN export http_proxy="<host:port>" && \
#    export https_proxy="<host:port>" && \
#    apt-get update && \
#    apt-get install -y monodevelop monodevelop-nunit mate-icon-theme-faenza lxappearance && \
#    rm -rf /var/lib/apt/lists/*


# without proxy use
RUN apt-get update && \
    apt-get install -y monodevelop monodevelop-nunit mate-icon-theme-faenza lxappearance && \
    rm -rf /var/lib/apt/lists/*

