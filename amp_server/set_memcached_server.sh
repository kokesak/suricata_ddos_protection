#/bin/bash

systemctl restart memcached || { echo "Failed to start memcached server!"; exit 1; }
ip route add $VICTIM_NETWORK via $SURICATA_IP
