# /bin/bash

IP=/sbin/ip
DNS='nameserver 8.8.8.8'

echo 'Adding route to the local network...'
$IP route add $VICTIM_NETWORK via $VICTIM_SURICATA_GW_IP dev $SURICATA_INTERFACE_NAME_VICTIM_NETWORK
test $? -ne 0 && { echo 'Failed (1)'; exit 1; }

# Can happen in virtual environment
echo 'Delete default route to local networwk (can cause problems sometimes)...'
$IP route del default via $HOST_PC_VICTIM_NETWORK_GW

echo 'Seting up dns.google.com as DNS server...'
echo "nameserver $DNS" >> /etc/resolv.conf
chattr -f +i /etc/resolv.conf
/etc/init.d/networking restart
test $? -ne 0 && { echo 'Failed (2)'; exit 1; }

echo 'Enabling Kernel IP forwarding...'
/bin/echo 1 > /proc/sys/net/ipv4/ip_forward

echo 'Setting NFQ for Suricata...'
iptables -I FORWARD -j NFQUEUE --queue-bypass
test $? -ne 0 && { echo 'Failed (3)'; exit 1; }

echo 'Restarting Suricata...'
systemctl restart suricata
test $? -ne 0 && { echo 'Failed (4)'; exit 1; }

echo 'Done!'
