#!/bin/bash
set -u

# Downloading bootstrap file
cd /home/jolicoin/bitcore-livenet/bin/mynode/data
if [ ! -d /home/jolicoin/bitcore-livenet/bin/mynode/data/data/blocks ] && [ "$(curl -Is https://${WEB}/${BOOTSTRAP} | head -n 1 | tr -d '\r\n')" = "HTTP/1.1 200 OK" ] ; then \
        wget https://${WEB}/${BOOTSTRAP}; \
        tar -xvzf ${BOOTSTRAP}; \
        rm ${BOOTSTRAP}; \
fi

# Create script to downloading new jolicoin.conf and replace the old one
echo "#!/bin/bash" > /usr/local/bin/new_config.sh
echo "Downloading new jolicoin.conf and replace the old one. Please wait..." >> /usr/local/bin/new_config.sh
echo "mv /home/jolicoin/bitcore-livenet/bin/mynode/data/jolicoin.conf /home/jolicoin/bitcore-livenet/bin/mynode/data/jolicoin.conf.bak" >> /usr/local/bin/new_config.sh
echo "wget https://raw.githubusercontent.com/dalijolijo/JOLIinsight-docker/master/jolicoin.conf -O /home/jolicoin/bitcore-livenet/bin/mynode/data/jolicoin.conf" >> /usr/local/bin/new_config.sh
echo "supervisorctl restart jolicoind" >> /usr/local/bin/new_config.sh
chmod 755 /usr/local/bin/new_config.sh

# Starting Supervisor Service
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
