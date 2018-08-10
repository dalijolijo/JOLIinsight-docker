#!/bin/bash
set -u

# Downloading bootstrap file
cd /home/jolicoin/bitcore-livenet/bin/mynode/data
if [ ! -d /home/jolicoin/bitcore-livenet/bin/mynode/data/data/blocks ] && [ "$(curl -Is https://${WEB}/${BOOTSTRAP} | head -n 1 | tr -d '\r\n')" = "HTTP/1.1 200 OK" ] ; then \
        wget https://${WEB}/${BOOTSTRAP}; \
        tar -xvzf ${BOOTSTRAP}; \
        rm ${BOOTSTRAP}; \
fi

# Create script to downloading additional nodes file and add nodes after start with 'docker exec j_o_l_i-insight-docker addnodes.sh'
echo "#!/bin/bash" > /usr/local/bin/addnodes.sh
echo "wget https://raw.githubusercontent.com/dalijolijo/JOLIinsight-docker/master/addnodes.conf -O /home/jolicoin/bitcore-livenet/bin/mynode/data/addnodes.conf" >> /usr/local/bin/addnodes.sh
echo "cat /home/jolicoin/bitcore-livenet/bin/mynode/data/addnodes.conf >> /home/jolicoin/bitcore-livenet/bin/mynode/data/jolicoin.conf" >> /usr/local/bin/addnodes.sh
echo "supervisorctl restart jolicoind" >> /usr/local/bin/addnodes.sh
chmod 755 /usr/local/bin/addnodes.sh

# Starting Supervisor Service
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
