#! /bin/bash

IP=/sbin/ip

echo 'Deleting default gw...'
$IP route delete default
test $? -ne 0 && { echo 'Failed (1)'; exit 1; }

echo 'Adding Suricata as default gw...'
$IP route add default via $VICTIM_SURICATA_GW_IP dev $VICTIM_INTERFACE_NAME
test $? -ne 0 && { echo 'Failed (2)'; exit 1; }
echo 'Done!'

echo 'Checking if ComplexHTTPServer (python module) is installed...'
python -c "import ComplexHTTPServer"
test $? -ne 0 && { echo 'Failed (3)'; exit 1; }
echo 'Done!'

echo 'Checking tmux tool is installed...'
tmux -V
test $? -ne 0 && { echo 'Failed (4)'; exit 1; }
echo 'Done!'
