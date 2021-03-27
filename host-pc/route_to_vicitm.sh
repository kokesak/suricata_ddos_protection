#! /bin/bash
IP=/sbin/ip
LOCAL_NETWORK='192.168.100.0/24'
SURICATA_INT='192.168.122.39'


echo 'Removing default way to the victim network...'
$IP route del $LOCAL_NETWORK dev virbr1 proto kernel scope link src 192.168.100.1
test $? -eq 1 && { echo 'Fail'; exit 1; }

echo 'Adding route through the suricata interface...'
$IP route add $LOCAL_NETWORK via $SURICATA_INT
test $? -eq 1 && { echo 'Fail'; exit 1; }
echo 'Done!'
