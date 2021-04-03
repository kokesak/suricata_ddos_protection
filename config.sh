#!/bin/bash
# File containing variables

VICTIM_IP="192.168.100.206"
VICTIM_NETWORK="192.168.100.0/24"
VICTIM_USR="root"
VICTIM_INTERFACE_NAME="ens3"
VICTIM_SURICATA_GW_IP="192.168.100.171"
VICTIM_HOME_PATH="/home/victim"

SURICATA_IP="192.168.122.39"
SURICATA_USR="root"
SURICATA_INTERFACE_NAME_VICTIM_NETWORK="ens9"

ATTACKER_IP="192.168.122.161"
ATTACKER_USR="root"

AMP_SERVER_IP="192.168.122.138"
AMP_SERVER_USR="root"

HOST_PC_VICTIM_NETWORK_GW="192.168.100.1"
HOST_PC_WANIF="wlp2s0"
HOST_PC_VICTIM_LANIF="vnet1"

# Number of replays that script performs
# OpenVPN response one loop last 30 seconds and generate 600 packets (simultaneously runs 10 OpenVPN replay)
# OpenVPN querry one loop generate 10 packets (simultaneously runs 10 OpenVPN replay, in less than 0.5 secnod)
# CLDAP response one loop generate aprox. 7200 packets (in less than 0.5 second)
# CLDAP querry one loop generate aprox. 2400 packets (in less than 0.5 second)
# SSDP response one loop generate aprox. 1200 packtes (in less than 0.5 second)
# SSDP querry one loop generate aprox. 100 packets (in less than 0.5 secons)
LOOPS="1"

# Number of seconds that script performs the attack
# This if for DNS, Memcached, slowloris
# For slowloris it is recomended to use higher number (eg. 45)
TIME="10"

# Number of packets to be sent
# NTP: 1 querry $PKTS generates aporx. 100 responses
# Floods
#
PKTS="10"
