# Lab11 - OpenVPN

red: sudo ettercap -Tq -i enp0s3 -M arp:remote /192.168.100.104// /192.168.100.253//

red@machine:~$ sudo tshark -i enp0s3 -f "host 192.168.100.104"

workathome:
 sudo openvpn --config /etc/openvpn/client.ovpn

 cyb@workathome:~$ ping 172.30.20.10



 [cyb@companyrouter ~]$ ps aux | grep openvpn
nobody       804  0.0  0.3  13816  9216 ?        Ss   06:55   0:00 /usr/sbin/openvpn --status /run/openvpn-server/status-server.log --status-version 2 --suppress-timestamps --cipher AES-256-GCM --data-ciphers AES-256-GCM:AES-128-GCM:AES-256-CBC:AES-128-CBC --config server.conf
cyb         3352  0.0  0.0   3876  1920 pts/0    S+   13:11   0:00 grep --color=auto openvpn
[cyb@companyrouter ~]$