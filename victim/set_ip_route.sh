#! /bin/bash

IP=/sbin/ip
# Interface of victim device
INTERFACE='ens3'
SURICATA_INT='192.168.100.171'

echo 'Deleting default gw...'
$IP route delete default
test $? -eq 1 && { echo 'Failed (1)'; exit 1; }

echo 'Adding Suricata as default gw...'
$IP route add default via $SURICATA_INT dev $INTERFACE
test $? -eq 1 && { echo 'Failed (2)'; exit 1; }
echo 'Done!'
