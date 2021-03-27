#!/bin/bash

ntpd
sleep 2
ntpq -p

/sbin/ip route add $VICTIM_NETWORK via $SURICATA_IP
/sbin/ip route
