#Copyright (c) 2018 The Bitcore BTX Core Developers (dalijolijo)

# Use an official Ubuntu runtime as a parent image
FROM dalijolijo/crypto-lib-ubuntu:16.04

LABEL maintainer="The Bitcore BTX Core Developers"

ENV GIT dalijolijo
USER root
WORKDIR /home
SHELL ["/bin/bash", "-c"]

RUN echo '*** JOLI Insight Explorer Docker Solution ***'

# Make ports available to the world outside this container
# Default Port = 8555
# RPC Port = 8556
# Tor Port = 9051
# ZMQ Port = 28332 (Block and Transaction Broadcasting with ZeroMQ)
# API Port = 3001 (Insight Explorer is avaiable at http://yourip:3001/insight and API at http://yourip:3001/insight/api)

# Creating jolicoin user
RUN adduser --disabled-password --gecos "" jolicoin && \
    usermod -a -G sudo,jolicoin jolicoin

# Add NodeJS (Version 8) Source
RUN apt-get update && \
    apt-get install -y curl \
                       sudo && \
    curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -

# Running updates and installing required packages
# New version libzmq5-dev needed?
RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y build-essential \
                            git \
                            libzmq3-dev \
                            nodejs \
                            supervisor \
                            vim \
                            wget

# Update Package npm to latest version
RUN npm i npm@latest -g

# Installing required packages for compiling
RUN apt-get install -y  apt-utils \
                        autoconf \
                        automake \
                        autotools-dev \
                        build-essential \
                        libboost-all-dev \
                        libevent-dev \
                        libminiupnpc-dev \
                        libssl-dev \
                        libtool \
                        pkg-config \
                        software-properties-common
RUN sudo add-apt-repository ppa:bitcoin/bitcoin
RUN sudo apt-get update && \
    sudo apt-get -y upgrade
RUN apt-get install -y libdb4.8-dev \
                       libdb4.8++-dev

#TODO: Sourcen einbinden

# Copy bitcored to bin/mynode
#RUN mkdir -p /home/bitcore/src/ && \
#    cd /home/bitcore/src/ && \
#    wget https://github.com/LIMXTEC/BitCore/releases/download/0.15.1.0/linux.Ubuntu.16.04.LTS-static-libstdc.tar.gz && \
#    tar xzf *.tar.gz && \
#    strip bitcored && \
#    rm *.tar.gz
TODO
# Cloning and Compiling JoliCoin Wallet
RUN mkdir -p /home/jolicoin/src/ && \
    cd /home/jolicoin && \
    git clone https://github.com/dalijolijo/BitCore.git && \
    cd BitCore && \
    ./autogen.sh && \
    ./configure --disable-dependency-tracking --enable-tests=no --without-gui --disable-hardening && \
    make && \
    cd /home/bitcore/BitCore/src && \
    strip bitcored && \
    chmod 775 bitcored && \
    cp bitcored /home/bitcore/src/ && \
    cd /home/bitcore && \
    rm -rf BitCore

# Install bitcore-node-joli
RUN cd /home/jolicoin && \
    git clone https://github.com/${GIT}/bitcore-node-joli.git bitcore-livenet && \
    cd /home/jolicoin/bitcore-livenet && \
    npm install

ENV JOLI_NET "/home/jolicoin/bitcore-livenet"

# Create Bitcore Node
# Hint: bitcore-node create -d <bitcoin-data-dir> mynode
RUN cd ${JOLI_NET}/bin && \
    chmod 777 bitcore-node && \
    ./bitcore-node create -d ${JOLI_NET}/bin/mynode/data mynode

# Install insight-api-joli
RUN cd ${JOLI_NET}/bin/mynode/node_modules && \
    git clone https://github.com/${GIT}/insight-api-joli.git && \
    cd ${BTX_NET}/bin/mynode/node_modules/insight-api-joli && \
    npm install

# Install insight-ui-joli
RUN cd ${JOLI_NET/bin/mynode/node_modules && \
    git clone https://github.com/${GIT}/insight-ui-joli.git && \
    cd ${JOLI_NET}/bin/mynode/node_modules/insight-ui-joli && \
    npm install

# Install bitcore-message-joli
RUN cd ${JOLI_NET}/bin/mynode/node_modules && \
    git clone https://github.com/${GIT}/bitcore-message-joli.git && \
    cd ${JOLI_NET}/bin/mynode/node_modules/bitcore-message-joli && \
    npm install save

# Install bitcore-lib-joli (not needed: part of another module)
#RUN cd ${JOLI_NET}/bin/mynode/node_modules && \
#    git clone https://github.com/${GIT}/bitcore-lib-joli.git && \
#    cd ${JOLI_NET}/bin/mynode/node_modules/bitcore-lib-joli && \
#    npm install

# Install bitcore-build-joli.git
RUN cd ${JOLI_NET}/bin/mynode/node_modules && \
    git clone https://github.com/${GIT}/bitcore-build-joli.git && \
    cd ${JOLI_NET}/bin/mynode/node_modules/bitcore-build-joli && \
    npm install

# Copy jolicoind to the correct bitcore-livenet/bin/ directory
RUN cp /home/jolicoin/src/jolicoind ${JOLI_NET}/bin/

# Copy JSON bitcore-node.json
COPY bitcore-node.json ${JOLI_NET}/bin/mynode/

# Copy Supervisor Configuration
COPY *.sv.conf /etc/supervisor/conf.d/

# Copy start script
COPY start.sh /usr/local/bin/start.sh
RUN rm -f /var/log/access.log && mkfifo -m 0666 /var/log/access.log && \
    chmod 755 /usr/local/bin/*

ENV TERM linux
CMD ["/usr/local/bin/start.sh"]
