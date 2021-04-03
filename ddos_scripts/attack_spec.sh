#!/bin/bash
# Config file that speciify certain attacks

## This is for DNS, Memcached
__TARGET_PORT=3500
__NUMBER_OF_THREADS=1

## This applies for Memcached
__PKTS_PER_SECONDS=300

## IP address for querry attacks
# This applies for NTP, DNS, Memcached querry
__SOURCE_IP_QUERRY="98.76.54.32"

## Slowloris and Slowread specification
__NUMBER_OF_CONNECTIONS=300
__CONNECTIONS_PER_SECOND=200

## Slowloris specification
__INTERVAL_BETWEEN_MESSAGES=10
__DATA_LENGTH=10


## Slowread sprecification
# interval between read operations in seconds
__INTERVAL_BETWEEN_READ=8
# bytes to read in single read operation
__BYTES_READ=16
# start of the range advertised window size
__WINDOW_START=128
# end of the range advertised window size
__WINDOW_END=256
# number of times to repeat same request in the connection. Use to
# multiply response size if server supports persistent connections.
__REPEAT_REQ=3
