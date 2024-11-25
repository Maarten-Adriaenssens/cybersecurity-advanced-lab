# Lab01 - Understanding the network + Attacker machine red

## Capture traffic using the CLI

Start at least the isprouter, the companyrouter, the dc and the win10 client in your environment. For now you can still use the credentials vagrant/vagrant on all machines.
Install the tcpdump utility on the companyrouter and figure out a way to sniff traffic origination from the win10 using tcpdump on the companyrouter.
Have a look at the ip configurations of the dc machine, the win10 client and the companyrouter.

Network Interfaces on companyrouter

- eth0: 192.168.100.253/24
- eth1: 172.30.0.254/24 (connected to dc)
- eth2: 172.30.20.254/24
- eth3: 172.30.100.254/24 (connected to win10)

Which interface on the companyrouter will you use to capture traffic from the dc to the internet?

- Interface `eth0`
- Reason: Traffic from dc (172.30.0.4) will route through eth1 to eth0 and then out to the internet via isprouter.

Which interface on the companyrouter would you use to capture traffic from dc to win10?

- Interface: eth1 (or both eth1 and eth3)
- Reason: Traffic from dc (172.30.0.4) to win10 (172.30.100.100) will travel through eth1 to eth3

Test this out by pinging from win10 to the companyrouter and from win10 to the dc. Are you able to see all pings in tcpdump on the companyrouter?

```bash
[cyb@companyrouter ~]$ sudo tcpdump -i eth3 icmp
[sudo] password for cyb:
dropped privs to tcpdump
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth3, link-type EN10MB (Ethernet), snapshot length 262144 bytes
14:43:17.855544 IP 172.30.100.100 > companyrouter: ICMP echo request, id 1, seq 2, length 40
14:43:17.855591 IP companyrouter > 172.30.100.100: ICMP echo reply, id 1, seq 2, length 40
14:43:18.858736 IP 172.30.100.100 > companyrouter: ICMP echo request, id 1, seq 3, length 40
14:43:18.858871 IP companyrouter > 172.30.100.100: ICMP echo reply, id 1, seq 3, length 40
14:43:19.873688 IP 172.30.100.100 > companyrouter: ICMP echo request, id 1, seq 4, length 40
14:43:19.873713 IP companyrouter > 172.30.100.100: ICMP echo reply, id 1, seq 4, length 40
14:43:20.889198 IP 172.30.100.100 > companyrouter: ICMP echo request, id 1, seq 5, length 40
14:43:20.889228 IP companyrouter > 172.30.100.100: ICMP echo reply, id 1, seq 5, length 40
```

Figure out a way to capture the data in a file. Copy this file from the companyrouter to your host and verify you can analyze this file with wireshark (on your host).

```bash
sudo tcpdump -i eth3 -w win10_to_router.pcap icmp
```

SSH from win10 to the companyrouter. When scanning with tcpdump you will now see a lot of SSH traffic passing by. How can you start tcpdump and filter out this ssh traffic?

```bash
sudo tcpdump -i eth3 not port 22
```

Start the web VM. Find a way to capture only HTTP traffic and only from and to the webserver-machine. Test this out by browsing to http://www.insecure.cyb from the isprouter machine using curl. This is a website that should be available in the lab environment. Are you able to see this HTTP traffic? Browse on the win10 client, are you able to see the same HTTP traffic in tcpdump, why is this the case?

## Part 1 Create the red machine

You are tasked to create a new virtual machine called red. This will be an attacker machine. You are free to use a kali virtual machine if you have enough disk space and memory. We do however suggest to install a clean debian machine without a graphical user interface. You can use any method you want (install from iso, osboxes, vagrant box, etc.). This has the advantage to be smaller in disk and memory footprint. Since kali is built upon debian, all attacker tools are installable on debian as well. Configure the network of your red machine by adding 1 interface and connecting it to the host-only network adapter (#2)

Refer to the network layout, this machine should be part of the yellow network. Configure this machine correctly in such a way that it has internet access and is able to connect to all other virtual machines of the environment.

## Part 2 Create your own network diagram and include all notes of the given setup

In the exercises of next week you will be given an overview of some features of the network. Using the red machine you will be able to attack some services and figure out what is insecure. For now, try to gain as much insight as possible in the network. Do not assume the current setup is perfect! Create your own network diagram and include all notes of the given setup*. From now on we expect you to build and improve your own notes and documentation each week. Try to answer and include the following questions in your overview:

### 1. What did you have to configure on your red machine to have internet and to properly ping web?

Network Adapter Configuration:
Red Machine (192.168.100.X):
Connect to Host-Only adapter #2

Set DNS server to isprouter

Add a default route to the network

```bash
sudo ip route add default via 192.168.100.254
```

### 2. What is the default gateway of each machine?

- Red Machine (192.168.100.102): 192.168.100.254
- Company Router (172.30.0.254 / 172.30.20.254 / 172.30.100.254 / 192.168.100.253): 192.168.100.254
- ISP Router (10.0.2.15 / 192.168.100.254): 10.0.2.2
- Web Server (172.30.20.10): 172.30.20.254
- Database (172.30.0.15): 172.30.0.254
- DC (172.30.0.4): 172.30.0.254

### 3. What is the DNS server of each machine?

- Red Machine (192.168.100.X254): 10.0.2.3
- Company Router (192.168.100.253): 10.0.2.3
- ISP Router (10.0.2.15 / 192.168.100.254): 10.0.2.3
- Web Server (172.30.20.10): 172.30.0.4 (DC)
- Database (172.30.0.15): 172.30.0.4 (DC)
- DC (172.30.0.4): 10.0.2.3

### 4. Which machines have a static IP and which use DHCP?

Static IPs:

- Red Machine: 192.168.100.254/24
- Company Router: 172.30.0.254 / 172.30.20.254 / 172.30.100.254 / 192.168.100.253
- ISP Router: 10.0.2.15 / 192.168.100.254/24
- Web Server: 172.30.20.10/24
- Database: 172.30.0.15/24
- DC: 172.30.0.4/24

DHCP:

- WinClient: 172.30.100.7/24

### 5. What routes should be configured and where, how do you make it persistent?

Red Machine (192.168.100.X):

Default route to access the internet via ISP Router:

```bash
sudo ip route add default via 192.168.100.254
```

Company Router:

Route traffic from internal networks to the ISP Router:

```bash
sudo ip route add default via 192.168.100.254
```

### 6. Which users exist on which machines?

Red Machine (192.168.100.102):

- User: red

Company Router (172.30.0.254 / 172.30.20.254 / 172.30.100.254 / 192.168.100.253):

- User: cyb

ISP Router (10.0.2.15 / 192.168.100.254):

- User: isprouter (aka root)

Web Server (172.30.20.10):

- User: cyb

Database (172.30.0.15):

- User: cyb

DC (172.30.0.4):

- User: cyb-dc

### What is the purpose (which processes or packages for example are essential) of each machine?

Investigate whether the DNS server of the company network is vulnerable to a DNS Zone Transfer "attack" as discussed above. What exactly does this attack involve? If possible, try to configure the server to prevent this attack. Document this update: How can you execute this attack or check if the DNS server is vulnerable and how can you fix it? Can you perform this "attack" both on Windows and Linux? Document your findings properly.

- This attack involves querying the DNS server for a zone transfer. This will return all DNS records for a domain. This can be used to gather information about the network and its services.
- Voor welk doel gaat de secundary server een zone transfer aangaan bij de primary?
  - Als de secundaire server een zone transfer aangaat bij de primary, dan zal de secundaire server de DNS records van de primary server overnemen. Dit is nod

Attack on red machine:

```bash
red@machine:~$ dig @172.30.0.4 insecure.cyb axfr
```

How to avoid:

```Powershell
PS C:\Users\cyb-dc.insecure> Set-DnsServerPrimaryZone -Name insecure.cyb -SecureSecondaries NoTransfer
```

Everything in the environment we gave you should be reproducible with your current knowledge. This means we expect you to be mindful and responsible. If a machine is not acting properly anymore you should be able to fix it OR create it completely from scratch. "Machine x stopped working" is not a valid excuse, ever!
