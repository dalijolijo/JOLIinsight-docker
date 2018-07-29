# Copyright (c) J_O_L_I_YEAR J_O_L_I_TEAM (J_O_L_I_AUTHOR)

# Use an official Ubuntu runtime as a parent image
FROM dalijolijo/crypto-lib-ubuntu:16.04

LABEL maintainer="J_O_L_I_TEAM"

ENV GIT dalijolijo
USER root
WORKDIR /home
SHELL ["/bin/bash", "-c"]

RUN echo '*** JOLI Insight Explorer Docker Solution ***'

# Make ports available to the world outside this container
# Default Port = J_O_L_I_DEFAULTPORT
# RPC Port = J_O_L_I_RPCPORT
# Tor Port = J_O_L_I_TORPORT
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

# Cloning JoliCoin Git repository
RUN mkdir -p /home/jolicoin/src/ && \
    cd /home/jolicoin && \
    git clone https://J_O_L_I_SOURCE

# Compiling JoliCoin Sources
RUN cd /home/jolicoin/J_O_L_I_SRC_DIR && \
    git checkout J_O_L_I_SRC_BRANCH && \
    J_O_L_I_COMPILE

# Strip jolicoind binary 
RUN cd /home/jolicoin/J_O_L_I_SRC_DIR/src && \
    strip jolicoind && \
    chmod 775 jolicoind && \
    cp jolicoind /home/jolicoin/src/

# Remove source directory 
RUN rm -rf /home/jolicoin/J_O_L_I_SRC_DIR

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
    sync && \
    ./bitcore-node create -d ${JOLI_NET}/bin/mynode/data mynode

# Install insight-api-joli
RUN cd ${JOLI_NET}/bin/mynode/node_modules && \
    git clone https://github.com/${GIT}/insight-api-joli.git && \
    cd ${JOLI_NET}/bin/mynode/node_modules/insight-api-joli && \
    npm install

# Install insight-ui-joli
RUN cd ${JOLI_NET}/bin/mynode/node_modules && \
    git clone https://github.com/${GIT}/insight-ui-joli.git && \
    cd ${JOLI_NET}/bin/mynode/node_modules/insight-ui-joli && \
    npm install

# Install bitcore-message-joli
RUN cd ${JOLI_NET}/bin/mynode/node_modules && \
    git clone https://github.com/${GIT}/bitcore-message-joli.git && \
    cd ${JOLI_NET}/bin/mynode/node_modules/bitcore-message-joli && \
    npm install save

# Install bitcore-lib-joli (not needed: part of another module)
RUN cd ${JOLI_NET}/bin/mynode/node_modules && \
    git clone https://github.com/${GIT}/bitcore-lib-joli.git && \
    cd ${JOLI_NET}/bin/mynode/node_modules/bitcore-lib-joli && \
    npm install

# Install bitcore-build-joli
RUN cd ${JOLI_NET}/bin/mynode/node_modules && \
    git clone https://github.com/${GIT}/bitcore-build-joli.git && \
    cd ${JOLI_NET}/bin/mynode/node_modules/bitcore-build-joli && \
    npm install

# Install bitcore-wallet-service
# See: https://github.com/dalijolijo/bitcore-wallet-service-joli/blob/master/installation.md
# Reference: https://github.com/m00re/bitcore-docker
# This will launch the BWS service (with default settings) at http://localhost:3232/bws/api.
# BWS needs mongoDB. You can configure the connection at config.js
#RUN cd ${JOLI_NET}/bin/mynode/node_modules && \
#    git clone https://github.com/${GIT}/bitcore-wallet-service-joli.git && \
#    cd ${JOLI_NET}/bin/mynode/node_modules/bitcore-wallet-service-joli && \
#    npm install
# Configuration needed before start
#RUN npm start

# Remove duplicate node_module 'bitcore-lib' to prevent startup errors such as:
#   "More than one instance of bitcore-lib found. Please make sure to require bitcore-lib and check that submodules do
#   not also include their own bitcore-lib dependency."
RUN rm -Rf cd ${JOLI_NET}/bin/mynode/node_modules/insight-api-mec/node_modules/bitcore-lib-mec
RUN rm -Rf cd ${JOLI_NET}/bin/mynode/node_modules/bitcore-node-mec/node_modules/bitcore-lib-mec
#RUN rm -Rf cd ${JOLI_NET}/bin/mynode/node_modules/bitcore-wallet-service/node_modules/bitcore-lib-mec

# Cleanup
RUN apt-get -y remove --purge build-essential && \
    apt-get -y autoremove && \
    apt-get -y clean

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
