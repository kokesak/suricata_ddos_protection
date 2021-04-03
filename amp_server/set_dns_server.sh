#/bin/bash

systemctl restart bind9 || { echo "Failed to start DNS server!"; exit 1; }
systemctl status bind9
ip route add $VICTIM_NETWORK via $SURICATA_IP
