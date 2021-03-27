# /bin/bash

DNS='nameserver 8.8.8.8'

echo "nameserver $DNS" >> /etc/resolv.conf

chattr -f +i /etc/resolv.conf

/etc/init.d/networking restart

echo 'Done!'
