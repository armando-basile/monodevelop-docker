FROM mono:5.12

MAINTAINER Armando Basile <armando@integrazioneweb.com>

COPY /docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD /bin/bash

# If Proxy can use
#RUN export http_proxy="<host:port>" && \
#    export https_proxy="<host:port>" && \
#    apt-get update && \
#    apt-get install -y monodevelop monodevelop-nunit && \
#    rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y monodevelop monodevelop-nunit && \
    rm -rf /var/lib/apt/lists/*


ADD docker-entrypoint.sh /docker-entrypoint.sh
