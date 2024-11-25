# Before Network Segmentation

## Company Router

```console
[cyb@companyrouter ~]$ ip -c a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:68:98:b2 brd ff:ff:ff:ff:ff:ff
    altname enp0s3
    inet 192.168.100.253/24 brd 192.168.100.255 scope global noprefixroute eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe68:98b2/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:9c:fb:15 brd ff:ff:ff:ff:ff:ff
    altname enp0s8
    inet 172.30.255.254/16 brd 172.30.255.255 scope global noprefixroute eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::24dd:253:703:1fd6/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
[cyb@companyrouter ~]$ ip route
default via 192.168.100.254 dev eth0 proto static metric 100
172.30.0.0/16 dev eth1 proto kernel scope link src 172.30.255.254 metric 101
192.168.100.0/24 dev eth0 proto kernel scope link src 192.168.100.253 metric 100
[cyb@companyrouter ~]$ systemctl list-units --type=service --state=running
  UNIT                     LOAD   ACTIVE SUB     DESCRIPTION                                 >
  auditd.service           loaded active running Security Auditing Service
  chronyd.service          loaded active running NTP client/server
  crond.service            loaded active running Command Scheduler
  dbus-broker.service      loaded active running D-Bus System Message Bus
  dhcpd.service            loaded active running DHCPv4 Server Daemon
  getty@tty1.service       loaded active running Getty on tty1
  gssproxy.service         loaded active running GSSAPI Proxy Daemon
  NetworkManager.service   loaded active running Network Manager
  rpcbind.service          loaded active running RPC Bind
  rsyslog.service          loaded active running System Logging Service
  sshd.service             loaded active running OpenSSH server daemon
  sssd-kcm.service         loaded active running SSSD Kerberos Cache Manager
  systemd-journald.service loaded active running Journal Service
  systemd-logind.service   loaded active running User Login Management
  systemd-udevd.service    loaded active running Rule-based Manager for Device Events and Fil>
  user@1002.service        loaded active running User Manager for UID 1002
  vboxadd-service.service  loaded active running vboxadd-service.service

LOAD   = Reflects whether the unit definition was properly loaded.
ACTIVE = The high-level unit activation state, i.e. generalization of SUB.
SUB    = The low-level unit activation state, values depend on unit type.
17 loaded units listed.
[cyb@companyrouter ~]$

[cyb@companyrouter ~]$ ip route
default via 192.168.100.254 dev eth0 proto static metric 100
172.30.0.0/24 dev eth1 proto kernel scope link src 172.30.0.254 metric 101
172.30.20.0/24 dev eth2 proto kernel scope link src 172.30.20.254 metric 102
172.30.100.0/24 dev eth3 proto kernel scope link src 172.30.100.254 metric 103
192.168.100.0/24 dev eth0 proto kernel scope link src 192.168.100.253 metric 100
[cyb@companyrouter ~]$ sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
[sudo] password for cyb:
[cyb@companyrouter ~]$ sudo iptables -A FORWARD -i eth3 -o eth2 -j ACCEPT
sudo iptables -A FORWARD -i eth2 -o eth3 -j ACCEPT
sudo iptables -A FORWARD -i eth0 -o eth2 -j ACCEPT
sudo iptables -A FORWARD -i eth2 -o eth0 -j ACCEPT
[cyb@companyrouter ~]$ sudo iptables -L -v -n
sudo iptables -t nat -L -v -n
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 ACCEPT     all  --  eth3   eth2    0.0.0.0/0            0.0.0.0/0
    0     0 ACCEPT     all  --  eth2   eth3    0.0.0.0/0            0.0.0.0/0
 3839 6907K ACCEPT     all  --  eth0   eth2    0.0.0.0/0            0.0.0.0/0
 1915 84666 ACCEPT     all  --  eth2   eth0    0.0.0.0/0            0.0.0.0/0

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
Chain PREROUTING (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain POSTROUTING (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
   30  1872 MASQUERADE  all  --  *      eth0    0.0.0.0/0            0.0.0.0/0
[cyb@companyrouter ~]$
```

## Red Machine

```console
red@machine:~$ ip -c a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:08:a7:b0 brd ff:ff:ff:ff:ff:ff
    inet 192.168.100.102/24 brd 192.168.100.255 scope global dynamic noprefixroute enp0s3
       valid_lft 33993sec preferred_lft 33993sec
    inet6 fe80::a00:27ff:fe08:a7b0/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
red@machine:~$ ip route
default via 192.168.100.254 dev enp0s3 proto dhcp src 192.168.100.102 metric 100
169.254.0.0/16 dev enp0s3 scope link metric 1000
192.168.100.0/24 dev enp0s3 proto kernel scope link src 192.168.100.102 metric 100
red@machine:~$
```

## IspRouter

```console
isprouter:~$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 08:00:27:b1:b3:fb brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:feb1:b3fb/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 08:00:27:2f:42:bc brd ff:ff:ff:ff:ff:ff
    inet 192.168.100.254/24 scope global eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe2f:42bc/64 scope link
       valid_lft forever preferred_lft forever
isprouter:~$ ip route
default via 10.0.2.2 dev eth0  metric 202
10.0.2.0/24 dev eth0 scope link  src 10.0.2.15
192.168.100.0/24 dev eth1 scope link  src 192.168.100.254
isprouter:~$
```

## Database

```console
[cyb@database ~]$ ip -c a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:85:77:8b brd ff:ff:ff:ff:ff:ff
    altname enp0s3
    inet 172.30.0.15/16 brd 172.30.255.255 scope global noprefixroute eth0
       valid_lft forever preferred_lft forever
[cyb@database ~]$ ip route
default via 172.30.255.254 dev eth0 proto static metric 100
172.30.0.0/16 dev eth0 proto kernel scope link src 172.30.0.15 metric 100
[cyb@database ~]$
```

## Webserver

```console
[cyb@web ~]$ ip -c a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:de:9a:fe brd ff:ff:ff:ff:ff:ff
    altname enp0s3
    inet 172.30.0.10/16 brd 172.30.255.255 scope global noprefixroute eth0
       valid_lft forever preferred_lft forever
    inet 172.30.10.101/16 brd 172.30.255.255 scope global secondary dynamic noprefixroute eth0
       valid_lft 470sec preferred_lft 470sec
[cyb@web ~]$ ip route
default via 172.30.255.254 dev eth0 proto static metric 100
172.30.0.0/16 dev eth0 proto kernel scope link src 172.30.0.10 metric 100
172.30.0.0/16 dev eth0 proto kernel scope link src 172.30.10.101 metric 100
[cyb@web ~]$
```

## DC

```console
PS C:\Users\cyb-dc.insecure> ipconfig /all

Windows IP Configuration

   Host Name . . . . . . . . . . . . : dc
   Primary Dns Suffix  . . . . . . . : insecure.cyb
   Node Type . . . . . . . . . . . . : Hybrid
   IP Routing Enabled. . . . . . . . : No
   WINS Proxy Enabled. . . . . . . . : No
   DNS Suffix Search List. . . . . . : insecure.cyb

Ethernet adapter Ethernet:

   Connection-specific DNS Suffix  . :
   Description . . . . . . . . . . . : Intel(R) PRO/1000 MT Desktop Adapter
   Physical Address. . . . . . . . . : 08-00-27-FE-B6-D7
   DHCP Enabled. . . . . . . . . . . : No
   Autoconfiguration Enabled . . . . : Yes
   Link-local IPv6 Address . . . . . : fe80::9445:a401:1320:f266%5(Preferred)
   IPv4 Address. . . . . . . . . . . : 172.30.0.4(Preferred)
   Subnet Mask . . . . . . . . . . . : 255.255.0.0
   Default Gateway . . . . . . . . . : 172.30.255.254
   DHCPv6 IAID . . . . . . . . . . . : 101187623
   DHCPv6 Client DUID. . . . . . . . : 00-01-00-01-2E-3B-AA-EA-08-00-27-FE-B6-D7
   DNS Servers . . . . . . . . . . . : ::1
                                       127.0.0.1
   NetBIOS over Tcpip. . . . . . . . : Enabled
```
