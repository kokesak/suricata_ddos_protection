# /bin/bash

echo 'Seting up dns.google.com as DNS server...'

DNS='nameserver 8.8.8.8'

echo "nameserver $DNS" >> /etc/resolv.conf

chattr -f +i /etc/resolv.conf

/etc/init.d/networking restart

echo 'Done!'
