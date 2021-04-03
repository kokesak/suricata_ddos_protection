#!/bin/bash

source ./config.sh

ATTACK_VECTOR=
VICTIM_IP=
ATTACK_TYPE=

GREEN='\033[0;32m' # Green Color
YELLOW='\033[0;33m'
RED='\033[0;31m' # RED Color
NC='\033[0m' # No Color

__POSSIBLE_ATTACK_VECTOR=("ntp" "dns" "cldap" "memcached" "openvpn"
                            "flood-syn" "flood-ack" "flood-rst" "floods"
                            "ssdp" "slowloris" "slowread")


print_help() {
    #
    # Help message
    #
    echo -e "${GREEN}Usage: launch_attack.sh [-a attack-vector] [-t attack-type] [-d victim-ip] [-l loops]"
    echo    "  Options are:"
    echo    "  -a, --attack-vector: ntp, dns, openvpn, cldap, memcached, flood-syn,"
    echo    "                       flood-ack, flood-rst, floods, ssdp, slowloris, slowread."
    echo    ""
    echo    "  -d, --victim-ip:     IPv4 address of a victim."
    echo    ""
    echo    "  -l, --loops:         Number of replays that script peforms (default 1),"
    echo    "                       This option is for OpenVPN, CLDAP, SSDP."
    echo    ""
    echo    "  -s, --time:          Number of seconds that script performs the attack (default 10),"
    echo    "                       This option is for DNS, Memcached, slowloris."
    echo    ""
    echo    "  -p, --packets:       Number of packets to be sent (default 10),"
    echo    "                       This option is for NTP, slowloris."
    echo    ""
    echo    "  -t, --attack-type:   Required option for AMPLIFICATION ATTACK,"
    echo    "                       can be either 'querry' or 'response',"
    echo    "                       specify if the attack should generate querries to the vulnurable server or responses,"
    echo    "                       from server."
    echo -e "                       AMPLIFICATION  ATTACKS: ntp, dns, cldap, openvpn, ssdp, memcached.${NC}"
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
        -p|--packets)
            PKTS="$2"
            shift 2
            ;;
        -s|--time)
            TIME="$2"
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

restart_suricata() {
    #
    # Restart suricata service
    #
    ssh -l "$SURICATA_USR" "$SURICATA_IP" \
        "systemctl restart suricata && echo 'Suricata restarted...'"
}

cp_active_rule_to_suricata() {
    local rule_file
    case $ATTACK_VECTOR in
        floods|flood-ack|flood-syn|flood-rst)
            rule_file="floods.rule" ;;
        *)
            rule_file="$ATTACK_VECTOR.rules" ;;
    esac
    echo "Copying $rule_file to Suricta /etc/suricata/my-rules ..."
    scp rules/$rule_file "$SURICATA_USR"@"$SURICATA_IP":/etc/suricata/my-rules/active.rules
    echo "Copying config files to Suricata /etc/sruicata ..."
    scp suricata/suricata.yaml suricata/threshold.config "$SURICATA_USR"@"$SURICATA_IP":/etc/suricata
    echo "Done!"

}

get_suricata_stats() {
    #
    # Get statistics from suricata
    #
    /bin/bash suricata/stats_suricata.sh
}

do_attack() {
    #
    # Connect to the attacker and do the attack
    #
    ssh -l "$ATTACKER_USR" "$ATTACKER_IP" \
        VICTIM_IP="$VICTIM_IP" \
        LOOPS="$LOOPS" \
        TIME="$TIME"\
        PKTS="$PKTS" \
        VICTIM_NETWORK=$VICTIM_NETWORK \
        SURICATA_IP=$SURICATA_IP \
        AMP_SERVER_IP=$AMP_SERVER_IP \
        ATTACK_VECTOR="$ATTACK_VECTOR" \
        ATTACK_TYPE="$ATTACK_TYPE" \
        /bin/bash < "attacker/attacker_steps.sh"
}

start_http_server() {
    #
    # Connect to the Vicitm IP and starts HTTP Server there on port 80
    #
    echo 'Creating new http server listening on port 80...'
    ssh -l "$VICTIM_USR" "$VICTIM_IP" \
        "pushd $VICTIM_HOME_PATH; \
            tmux new-session -s my_http_server -d 'python -m ComplexHTTPServer 80 >/var/log/my_http_server.out'; \
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
        "tmux kill-session -t my_http_server"
    test $? -eq 0 && echo "Server stopped successfully!"
}



##### MAIN

check_arguments $@

test -z $ATTACK_VECTOR  && { echo -e "${RED}Attack vector not specified!${NC}"; exit 1; }
test -z $VICTIM_IP      && { echo -e "${RED}Victim IP address not specified!${NC}"; exit 1; }

case "$ATTACK_VECTOR" in
    slowloris|slowread)
        start_http_server

        cp_active_rule_to_suricata

        restart_suricata

        do_attack

        get_suricata_stats

        stop_http_server
        ;;
    *)
        cp_active_rule_to_suricata

        restart_suricata

        do_attack

        get_suricata_stats
        ;;
esac
