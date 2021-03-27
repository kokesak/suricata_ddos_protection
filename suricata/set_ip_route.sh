# /bin/bash

IP=/sbin/ip
LOCAL_NETWORK='192.168.100.0/24'
LOCAL_DEFAULT_GW='192.168.100.1' # Default gateway for suricata for local network
INT_NAME='ens9'
INT_IP='192.168.100.171'

DNS='nameserver 8.8.8.8'

echo 'Adding route to the local network...'
$IP route add $LOCAL_NETWORK via $INT_IP dev $INT_NAME
test $? -eq 1 && { echo 'Failed (1)'; exit 1; }

# Can happen in virtual environment
echo 'Delete default route to local networwk (can cause problems sometimes)...'
$IP route del default via $LOCAL_DEFAULT_GW

echo 'Seting up dns.google.com as DNS server...'
echo "nameserver $DNS" >> /etc/resolv.conf
chattr -f +i /etc/resolv.conf
/etc/init.d/networking restart
test $? -eq 1 && { echo 'Failed (2)'; exit 1; }

echo 'Setting NFQ for Suricata...'
iptables -I FORWARD -j NFQUEUE --queue-bypass
test $? -eq 1 && { echo 'Failed (3)'; exit 1; }

echo 'Restarting Suricata...'
systemctl restart suricata
test $? -eq 1 && { echo 'Failed (4)'; exit 1; }

echo 'Done!'
