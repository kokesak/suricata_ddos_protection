#/bin/bash

IP=/sbin/ip

$IP route add $VICTIM_NETWORK via $SURICATA_IP
test $? -eq 1 && { echo 'Failed (1)'; exit 1; }

make -C /root/ddos_scripts/dns
make -C /root/ddos_scripts/memcache
echo "Attacker set up complete!"
