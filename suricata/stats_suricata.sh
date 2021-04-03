#!/bin/bash

source ./config.sh

ssh -l "$SURICATA_USR" "$SURICATA_IP" /bin/bash <<'EOT'
            while [ $? -eq 0 ]; do
                sleep 1
                suricatasc -c dump-counters >suricata.dump.out.json
                jq .message suricata.dump.out.json | grep -q 'stats not yet synchronized'
            done
            GREEN='\033[0;32m'
            NC='\033[0m'
            echo -e "${GREEN}Total packets:         ${NC}$(jq .message.decoder.ipv4 suricata.dump.out.json)"
            echo -e "${GREEN}Accepted packets:      ${NC}$(jq .message.ips.accepted suricata.dump.out.json)"
            echo -e "${GREEN}Droped packets:        ${NC}$(jq .message.ips.blocked suricata.dump.out.json)"
            echo -e "${GREEN}Alerts generated:      ${NC}$(jq .message.detect.alert suricata.dump.out.json)"
            echo -e "${GREEN}Average pkt size:      ${NC}$(jq .message.decoder.avg_pkt_size suricata.dump.out.json)"
            echo -e "${GREEN}Max pkt size:          ${NC}$(jq .message.decoder.max_pkt_size suricata.dump.out.json)"
            echo -e "${GREEN}Total bytes:           ${NC}$(jq .message.decoder.bytes suricata.dump.out.json)"
            echo -e "${GREEN}Total fragments:       ${NC}$(jq .message.defrag.ipv4.fragments suricata.dump.out.json)"
            echo -e "${GREEN}Reassembled fragments: ${NC}$(jq .message.defrag.ipv4.reassembled suricata.dump.out.json)"
            echo -e "${GREEN}Memory used (bytes):   ${NC}$(jq .message.flow.memuse suricata.dump.out.json)"

            rm suricata.dump.out.json
EOT
