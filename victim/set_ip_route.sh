#! /bin/bash

source ../config.sh

IP=/sbin/ip

echo 'Deleting default gw...'
$IP route delete default
test $? -eq 1 && { echo 'Failed (1)'; exit 1; }

echo 'Adding Suricata as default gw...'
$IP route add default via $VICTIM_SURICATA_GW_IP dev $VICTIM_INTERFACE_NAME
test $? -eq 1 && { echo 'Failed (2)'; exit 1; }
echo 'Done!'
