#/bin/bash

# Script that allows the victim use outer newtork (in case of virtual environment)


IPTABLES=/sbin/iptables

# enable ip forwarding in the kernel
echo 'Enabling Kernel IP forwarding...'
/bin/echo 1 > /proc/sys/net/ipv4/ip_forward

# flush rules and delete chains
echo 'Flushing rules and deleting existing chains...'
$IPTABLES -F
$IPTABLES -X

# enable masquerading to allow LAN internet access
echo 'Enabling IP Masquerading and other rules...'
$IPTABLES -t nat -A POSTROUTING -o $HOST_PC_VICTIM_LANIF -j MASQUERADE
$IPTABLES -A FORWARD -i $HOST_PC_VICTIM_LANIF -o $HOST_PC_WANIF -m state --state RELATED,ESTABLISHED -j ACCEPT
$IPTABLES -A FORWARD -i $HOST_PC_WANIF -o $HOST_PC_VICTIM_LANIF -j ACCEPT

$IPTABLES -t nat -A POSTROUTING -o $HOST_PC_WANIF -j MASQUERADE
$IPTABLES -A FORWARD -i $HOST_PC_WANIF -o $HOST_PC_VICTIM_LANIF -m state --state RELATED,ESTABLISHED -j ACCEPT
$IPTABLES -A FORWARD -i $HOST_PC_VICTIM_LANIF -o $HOST_PC_WANIF -j ACCEPT

echo 'Done!'
