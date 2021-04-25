#!/bin/bash
# Config file that speciify certain attacks

## This is for DNS, Memcached-stat
__TARGET_PORT=3500
__NUMBER_OF_THREADS=1

# This applies for floods attacks
__TARGET_PORT_FLOOD=80

## This applies for Memcached-stat
__PKTS_PER_SECONDS=300

## IP address for querry attacks
# This applies for NTP, DNS, Memcached-stat all type query
__SOURCE_IP_QUERY="192.168.122.99"

## Rate at which nping sends packets
# This applies for Memcached-get
__RATE="900"

## Slowloris and Slowread specification
__NUMBER_OF_CONNECTIONS=200
__CONNECTIONS_PER_SECOND=200

## Slowloris specification
__INTERVAL_BETWEEN_MESSAGES=10
__DATA_LENGTH=10


## Slowread sprecification
# interval between read operations in seconds
__INTERVAL_BETWEEN_READ=10
# bytes to read in single read operation
__BYTES_READ=256
# start of the range advertised window size
__WINDOW_START=512
# end of the range advertised window size
__WINDOW_END=1024
# number of times to repeat same request in the connection. Use to
# multiply response size if server supports persistent connections.
__REPEAT_REQ=1

# This is for tcpreplay, we also need to set mac addresses in virtual environment
__ATTACKER_MAC_ADDR="52:54:00:a9:3f:df"
# Suricat's interface that is NOT connected to the victim's network
__SURICATA_MAC_ADDR="52:54:00:2d:4c:c4"



