FROM ubuntu:16.04 as base

ENV DEBIAN_FRONTEND=noninteractive TERM=xterm
RUN echo "export > /etc/envvars" >> /root/.bashrc && \
    echo "export PS1='\[\e[1;31m\]\u@\h:\w\\$\[\e[0m\] '" | tee -a /root/.bashrc /etc/skel/.bashrc && \
    echo "alias tcurrent='tail /var/log/*/current -f'" | tee -a /root/.bashrc /etc/skel/.bashrc

RUN apt-get update
RUN apt-get install -y locales && locale-gen en_US.UTF-8 && dpkg-reconfigure locales
ENV LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# Runit
RUN apt-get install -y --no-install-recommends runit
# There is no logging outout in Kong right now. Trying to run it directly so I can see what's going on.
# Just starting an empty while loop so I can run it using other options without having to re-build every time...
CMD bash -c 'export > /etc/envvars && while true; do sleep 10; done'

# Utilities
RUN apt-get install -y --no-install-recommends vim less net-tools inetutils-ping wget curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common jq psmisc iproute python ssh rsync gettext-base

#dependencies
RUN apt-get install -y openssl libpcre3 procps perl

#kong
RUN curl -L https://bintray.com/kong/kong-community-edition-deb/download_file?file_path=dists/kong-community-edition-0.11.2.xenial.all.deb > kong.deb && \
    dpkg -i kong*.deb && \
    rm kong*.deb

# Nodejs
RUN wget -O - https://nodejs.org/dist/v8.11.1/node-v8.11.1-linux-x64.tar.gz | tar xz
RUN mv node* node
ENV PATH=$PATH:/node/bin

#kongfig
RUN npm install -g kongfig

COPY kong.conf /etc/kong/kong.conf

# Add runit services
COPY sv /etc/service 
ARG BUILD_INFO
LABEL BUILD_INFO=$BUILD_INFO

