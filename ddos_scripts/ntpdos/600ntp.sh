#!/bin/bash

for i in {1..60}; do
    for j in {1..10}; do
        bittwiste -I ntp-client-message.pcap -O ntp-client-message2.pcap -T ip -s 2.2.$i.$j
        bittwist -i eth0 ntp-client-message2.pcap -l 1
        rm -f ntp-client-message2.pcap
    done
done
