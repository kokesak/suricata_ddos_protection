#!/bin/bash

ntpd || { echo "Failed to start ntp server!"; exit 1; }
sleep 2
ntpq -p

/sbin/ip route add $VICTIM_NETWORK via $SURICATA_IP
/sbin/ip route
