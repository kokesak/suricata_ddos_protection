#!/bin/bash

VICTIM="$1" # Victim IP address
LOOPS="$2"
TEMP_DIR="$3"

source ../attack_spec.sh

tcpprep -a server -o openvpn.cach -i openvpn-querry.pcapng

while [ $LOOPS -gt 0 ]
do
    IP=$(echo $((RANDOM%254 + 1)))
    tcprewrite \
	    --endpoints="$VICTIM":"192.168.122.$IP"\
        --enet-smac=$__SURICATA_MAC_ADDR,$__ATTACKER_MAC_ADDR \
	    --enet-dmac=$__ATTACKER_MAC_ADDR,$__SURICATA_MAC_ADDR \
	    -c openvpn.cach -i openvpn-querry.pcapng \
	    -o $TEMP_DIR/openvpn.$BASHPID.pcapng --dlt=enet

    tcpreplay \
	    -K -i eth0 -I eth0 -l 30 \
	    -c openvpn.cach $TEMP_DIR/openvpn.$BASHPID.pcapng

    LOOPS=$(( $LOOPS - 1 ))
done
