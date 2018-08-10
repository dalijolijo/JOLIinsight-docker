# JOLIinsight-docker
## JoliCoin (JOLI) Insight Explorer Docker Solution

### Docker-CE - maintained by the Docker project - supports the following distribution versions:
* CentOS 7.4 (x86_64-centos-7)
* Fedora 26 (x86_64-fedora-26)
* Fedora 27 (x86_64-fedora-27)
* Fedora 28 (x86_64-fedora-28)
* Debian 7 (x86_64-debian-wheezy)
* Debian 8 (x86_64-debian-jessie)
* Debian 9 (x86_64-debian-stretch)
* Debian 10 (x86_64-debian-buster)
* Ubuntu 14.04 LTS (x86_64-ubuntu-trusty)
* Ubuntu 16.04 LTS (x86_64-ubuntu-xenial)
* Ubuntu 17.10 (x86_64-ubuntu-artful)
* Ubuntu 18.04 LTS (x86_64-ubuntu-bionic)

## Deployment of Docker Solution
Login as root, then only run the following script:
```sh
sudo bash -c "$(curl -fsSL https://github.com/dalijolijo/JOLIinsight-docker/raw/master/j_o_l_i-insight-docker.sh)"
```

## Replace existing jolicoin.conf
Modify [jolicoin.conf](https://github.com/dalijolijo/JOLIinsight-docker/blob/master/jolicoin.conf) and trigger the new_config.sh script inside the running docker container with:
```sh
sudo docker exec j_o_l_i-insight-docker new_config.sh
```

## Build/run (only for docker image development)
```sh
docker build -t dalijolijo/j_o_l_i-insight-docker .
docker push dalijolijo/j_o_l_i-insight-docker
docker run --rm --name j_o_l_i-insight-docker -p J_O_L_I_DEFAULTPORT:J_O_L_I_DEFAULTPORT -p J_O_L_I_RPCPORT:J_O_L_I_RPCPORT -p J_O_L_I_TORPORT:J_O_L_I_TORPORT -p 28332:28332 -p 3001:3001 dalijolijo/j_o_l_i-insight-docker
```
