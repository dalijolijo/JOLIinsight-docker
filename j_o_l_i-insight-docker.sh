#!/bin/bash
# Copyright (c) J_O_L_I_YEAR J_O_L_I_TEAM (J_O_L_I_AUTHOR)
# Script btx-insight-docker.sh
#set -e

#
# Define Variables for JOLI Insight
#
GIT_REPO="dalijolijo"
GIT_PROJECT="JOLIinsight-docker"
DOCKER_REPO="dalijolijo"
IMAGE_NAME="j_o_l_i-insight-docker"
IMAGE_TAG="16.04"
CONTAINER_NAME="j_o_l_i-insight-docker"
DEFAULT_PORT="J_O_L_I_DEFAULTPORT"
RPC_PORT="J_O_L_I_RPCPORT"
TOR_PORT="J_O_L_I_TORPORT"
ZMQ_PORT="28332"
API_PORT="3001"
WEB="bitcore.cc" # without "https://" and without the last "/" (only HTTPS accepted)
BOOTSTRAP="bootstrap.tar.gz"

#
# Color definitions
#
RED='\033[0;31m'
GREEN='\033[0;32m'
NO_COL='\033[0m'
JOLI_COL='J_O_L_I_COLOR'
 
clear
printf "\n\nRUN ${JOLI_COL}J_O_L_I_COIN (JOLI)${NO_COL} INSIGHT DOCKER SOLUTION\n"

#
# Docker Installation
#
if ! type "docker" > /dev/null; then
  curl -fsSL https://get.docker.com | sh
fi

#
# Firewall Setup
#
printf "\nDownload needed Helper-Scripts"
printf "\n------------------------------\n"
wget https://raw.githubusercontent.com/${GIT_REPO}/${GIT_PROJECT}/master/check_os.sh -O check_os.sh
chmod +x ./check_os.sh
source ./check_os.sh
rm ./check_os.sh
wget https://raw.githubusercontent.com/${GIT_REPO}/${GIT_PROJECT}/master/firewall_config.sh -O firewall_config.sh
chmod +x ./firewall_config.sh
source ./firewall_config.sh ${DEFAULT_PORT} ${RPC_PORT} ${TOR_PORT} ${ZMQ_PORT} ${API_PORT}
rm ./firewall_config.sh

#
# Run the docker container from JOLI Insight Docker Image
#
printf "\nStart ${JOLI_COL}JoliCoin (JOLI)${NO_COL} Insight Docker Container"
printf "\n--------------------------------------------\n"
sudo docker ps | grep ${CONTAINER_NAME} >/dev/null
if [ $? -eq 0 ]; then
    printf "${RED}Conflict! The container name \'${CONTAINER_NAME}\' is already in use.${NO_COL}\n"
    printf "\nDo you want to stop the running container to start the new one?\n"
    printf "Enter [Y]es or [N]o and Hit [ENTER]: "
    read STOP

    if [[ $STOP =~ "Y" ]] || [[ $STOP =~ "y" ]]; then
        docker stop ${CONTAINER_NAME}
    else
        printf "\nDocker Setup Result"
        printf "\n-------------------\n"
        printf "${RED}Canceled the Docker Setup without starting ${JOLI_COL}JoliCoin (JOLI)${NO_COL} Insight Docker Container.${NO_COL}\n\n"
        exit 1
    fi
fi
docker rm ${CONTAINER_NAME} 2>/dev/null

#
# Run JOLI Insight Docker Container
#
docker run \
 --rm \
 -p ${DEFAULT_PORT}:${DEFAULT_PORT} \
 -p ${RPC_PORT}:${RPC_PORT} \
 -p ${TOR_PORT}:${TOR_PORT} \
 -p ${ZMQ_PORT}:${ZMQ_PORT} \
 -p ${API_PORT}:${API_PORT} \
 --detach \
 --name ${CONTAINER_NAME} \
 -e WEB="${WEB}" \
 -e BOOTSTRAP="${BOOTSTRAP}" \
 ${DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG}

#
# Show result and give user instructions
#
sleep 5
clear
printf "\n${JOLI_COL}JoliCoin (JOLI)${GREEN} Insight Docker Solution${NO_COL}\n"
sudo docker ps | grep ${CONTAINER_NAME} >/dev/null
if [ $? -ne 0 ];then
    printf "${RED}Sorry! Something went wrong. :(${NO_COL}\n"
else
    printf "${GREEN}GREAT! Your ${JOLI_COL}JoliCoin (JOLI)${GREEN} Insight Docker is running now! :)${NO_COL}\n"
    printf "\nShow your running Docker Container \'${CONTAINER_NAME}\' with ${GREEN}'docker ps'${NO_COL}\n"
    sudo docker ps | grep ${CONTAINER_NAME}
    printf "\nJump inside the ${JOLI_COL}JoliCoin (JOLI)${NO_COL} Insight Docker Container with ${GREEN}'docker exec -it ${CONTAINER_NAME} bash'${NO_COL}\n"
    printf "\nCheck Log Output of ${JOLI_COL}JoliCoin (JOLI)${NO_COL} Insight with ${GREEN}'docker logs ${CONTAINER_NAME}'${NO_COL}\n"
    printf "${GREEN}HAVE FUN!${NO_COL}\n\n"
fi
