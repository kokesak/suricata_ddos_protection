#/bin/bash

systemctl restart memcached || { echo "Failed to start memcached server!"; exit 1; }
systemctl status memcached
ip route add $VICTIM_NETWORK via $SURICATA_IP
