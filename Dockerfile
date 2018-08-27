FROM mono:5.12

MAINTAINER Armando Basile <armando@integrazioneweb.com>

ENTRYPOINT ["/usr/bin/monodevelop"]

# If use a proxy can use
# RUN export http_proxy="<host:port>" && \
#    export https_proxy="<host:port>" && \
#    apt-get update && \
#    apt-get install -y monodevelop monodevelop-nunit && \
#    rm -rf /var/lib/apt/lists/*


RUN apt-get update && \
    apt-get install -y monodevelop monodevelop-nunit && \
    rm -rf /var/lib/apt/lists/*

