# Suricata DDoS protection
This is my code for Bachelor Thesis 2021 at Brno University of Technology.

## Requriements
I used [Virtual Machine Manager](https://virt-manager.org/) for creating VMs.
All machines must be accesible via SSH (root) user and have certain packages installed.

### Victim
For Slowloris attack we need to run HTTP server on Vicitm machine. I use ComplexHTTPServer.
```sh
pip install complexhttpserver
```

### Sruciata 
I used Suricata 6.0.2. How to install Suricata, please refer to the offical [document page](https://suricata.readthedocs.io/en/suricata-6.0.2/).
Emergin rules may be find here: https://rules.emergingthreats.net/open/suricata-6.0.1/

### Amplification server
For NTP DDoS attack it is required that version of NTP is less than ntpd-4.2.7p26. I used ntp-4.2.6p2.

```sh
curl https://www.eecis.udel.edu/~ntp/ntp_spool//ntp4/ntp-4.2/ntp-4.2.6p2.tar.gz -o ntp-4.2.6p2.tar.gz
tar -xf ntp-4.2.6p2.tar.gz
cd ntp-4.2.6p2
./configure
make
make install
```
Make sure that the following lines are commented out in `/etc/ntp.conf`:
```
#restrict default -4 nomodify nopeer noquery notrap
#restrict default -6 nomodify nopeer noquery notrap
```

#

For Memcached server we need to install and run this service on UDP port 11211. My version of memcached is: 1.4.25-2ubuntu1.5.
Ubuntu 16.04:
```sh
sudo apt-get install memcached libmemcached-tools
```
For listening on UDP port we need to add this line to the `/etc/memcached.conf` file.
```txt
-U 11211
```
Check that Memcached serivce is running:
```txt
systemctl restart memcached && systemctl status memcached
```
#

For DNS server we need to install following packages on Ubuntu:
```sh
sudo apt install bind9 dnsutils
```
We need add follwoing lines to the `/etc/bind/named.conf.options` file:
```
allow-query { any; };
```

Optionally we can have those lines in `/etc/bind/named.conf.default-zones`
```
zone "." {
     type hint;
     file "/etc/bind/mydb.root";
};
```
Where `mydb.root` file has the content found here: http://www.internic.net/domain/named.root

#### Attacker
There are severl utilites which may be required. I use Kali Linux 2020.4.
| Attack | Utility |
| ------ | ------ |
| NTP | perl (version: perl 5) |
| DNS, CLDAP, MEMCACHED | gcc |
| OpenVPN, SSDP | [tcpreplay](https://www.xmodulo.com/how-to-install-tcpreplay-on-linux.html) |
| Floods | [hping3](https://tools.kali.org/information-gathering/hping3) |
| Slowloris, Slowread | [SlowHTTPTest](https://tools.kali.org/stress-testing/slowhttptest), [slowloris](https://pypi.org/project/pyslowloris/) |

Note that there may be more libraries and dependecies required that are not mention here.

### Usage
Edit `config.sh` to reflect your testing environment. In `ddos_scripts/attack_spec.sh` are some specifications for certain attacks, this should also be modified. Then run `set_up.sh` and `launch_test.sh`.

For `set_up.sh` and `launch_test.sh` use option `-h` or`--help` to get information how to use them.

## LICENSE
This code is under GNUv3 License. See `LICENSE` file for more.
All the DDoS script that are not written by me are properly refered to their original GitHub page.
