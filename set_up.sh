#!/bin/bash

source ./config.sh

GREEN='\033[0;32m' # Green Color
YELLOW='\033[0;33m'
RED='\033[0;31m' # RED Color
NC='\033[0m' # No Color

USER_CHOICE="$1"

print_help(){
    #
    # Help message
    #
    echo -e "${GREEN}Usage: set_up.sh [target]"
    echo    "  Target can be one of the following:"
    echo    "       suricata, ntp, attacker, victim, memcached"
    echo    ""
    echo    "  Be aware that set up of ntp must be run after attacker has been"
    echo    "  set up at least once!"
    echo -e "  IP addresses are specified in config.sh file${NC}"

}

case "$USER_CHOICE" in
    "victim")
        ssh -l "$VICTIM_USR" "$VICTIM_IP" \
            VICTIM_SURICATA_GW_IP="$VICTIM_SURICATA_GW_IP"  VICTIM_INTERFACE_NAME="$VICTIM_INTERFACE_NAME" \
            /bin/bash <"victim/set_ip_route.sh"
        ;;
    "suricata")
        # TODO suricata-update?
        # set routes on Suricata
        scp rules/*.rules "$SURICATA_USR@$SURICATA_IP:/etc/suricata/my-rules"
        scp suricata/suricata.yaml suricata/threshold.config "$SURICATA_USR@$SURICATA_IP:/etc/suricata/"
        scp suricata/default_startup.config "$SURICATA_USR@$SURICATA_IP:/etc/default/suricata"

        ssh -l "$SURICATA_USR" "$SURICATA_IP" \
            VICTIM_NETWORK="$VICTIM_NETWORK" VICTIM_SURICATA_GW_IP="$VICTIM_SURICATA_GW_IP" \
            SURICATA_INTERFACE_NAME_VICTIM_NETWORK="$SURICATA_INTERFACE_NAME_VICTIM_NETWORK" \
            HOST_PC_VICTIM_NETWORK_GW="$HOST_PC_VICTIM_NETWORK_GW" \
            /bin/bash <"suricata/set_ip_route.sh"

       ;;
    "host-pc")
        #
        # Set host-pc so Victim si able to communicate with outside world
        #
        echo -e "${YELLOW}This command must be run as root!${NC}"
        sudo HOST_PC_VICTIM_LANIF="$HOST_PC_VICTIM_LANIF" HOST_PC_WANIF="$HOST_PC_WANIF" \
            /bin/bash "host-pc/allow_masquerading.sh"
        ;;
    "attacker")
        #
        # Copy ddos scripts to the attacker machine
        scp -r ddos_scripts/ "$ATTACKER_USR@$ATTACKER_IP:/root/"

        ssh -l "$ATTACKER_USR" "$ATTACKER_IP" \
            VICTIM_NETWORK="$VICTIM_NETWORK" \
            SURICATA_IP="$SURICATA_IP" \
            /bin/bash <"attacker/set_up_attacker.sh"
        ;;
    "ntp")
        echo -e "${YELLOW}This must be run after attacker has been set up!${NC}"

        scp amp_server/ntp.conf "$AMP_SERVER_USR@$AMP_SERVER_IP:/etc"

        ssh -l "$AMP_SERVER_USR" "$AMP_SERVER_IP" \
            VICTIM_NETWORK="$VICTIM_NETWORK" \
            SURICATA_IP="$SURICATA_IP" \
            /bin/bash <"amp_server/set_ntp_server.sh"

        # Add 600 entries to the ntp server
        # https://samsclass.info/124/proj14/p6x-NTP-DrDOS.htm
        echo -e "${YELLOW}This can take a while...${NC}"
        ssh -l "$ATTACKER_USR" "$ATTACKER_IP" \
            "pushd /root/ddos_scripts/ntpdos; /bin/bash 600ntp.sh >/var/log/600ntp.sh 2>/var/log/600ntp.err; popd"
        ;;
    "memcached")
        scp amp_server/memcached.conf "$AMP_SERVER_USR@$AMP_SERVER_IP:/etc"

        ssh -l "$AMP_SERVER_USR" "$AMP_SERVER_IP" \
            VICTIM_NETWORK="$VICTIM_NETWORK"\
            SURICATA_IP="$SURICATA_IP" \
            /bin/bash <"amp_server/set_memcached_server.sh"
        ;;
    "dns")
        scp amp_server/named.conf.default-zones amp_server/named.conf.options amp_server/mydb.root \
            "$AMP_SERVER_USR@$AMP_SERVER_IP:/etc/bind/"

        ssh -l "$AMP_SERVER_USR" "$AMP_SERVER_IP" \
             VICTIM_NETWORK="$VICTIM_NETWORK"\
             SURICATA_IP="$SURICATA_IP" \
             /bin/bash <"amp_server/set_dns_server.sh"
        ;;
    *)
        echo -e "${RED}Wrong argument: '$1'!${NC}"
        print_help
        exit 1
esac
