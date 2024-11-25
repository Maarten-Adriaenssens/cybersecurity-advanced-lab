# La02b

## Attacker virtual machine red

Use your documentation from lecture 1 and configure the red machine in such a way that this machine can ping ALL other devices of the environment if that wasn't the case yet (similar questions from lecture 1).

- What routes do you need to add?
  - A default (static) route to the internal 'company' network
- What is the default gateway?
  - 172.30.255.254 (companyrouter)
- Does your red have internet? If not, is it possibly? Why not OR how?
  - I already fixed the internet connection in the previous lab. default (static) route to isprouter.

## The insecure "fake internet" host only network

In this environment, the host-only network that was created when setting up the environment can be seen as an "insecure" network. Assume hackers can create machines and do whatever they want in this network. The red machine symbolizes this metaphor. companyrouter is the bridge between the internal company network and the "external" (fake internet) network.

- From your red machine perform the following red team attacks. Make sure to improve your documentation for all "insecure" stuff you notice.

- Use a web browser to browse to <http://www.insecure.cyb>

- Use a web browser to browse to <http://www.insecure.cyb/cmd> and test out this insecure application
  - ' OR '1'='1 of niets ingeven geeft een vlag.
  - **FLAG-852761**

- Perform a default nmap scan on all machines

### Enumerate the most interesting ports (you found in the previous step) by issuing a service enumeration scan (banner grab scan)

What database software is running on the database machine? What version?

Try to search for a nmap script to brute-force the database. Another (even easier tool) is called hydra (<https://github.com/vanhauser-thc/thc-hydra>). Search online for a good wordlist. For example: <https://github.com/danielmiessler/SecLists> We suggest to try the default username of the database software and attack the database machine. Another interesting username worth a try is "toor".

```linux
wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/10k-most-common.txt -O passwords.txt


red@machine:~$ hydra -L users.txt -P passwords.txt 172.30.0.5 mysql
Hydra v9.4 (c) 2022 by van Hauser/THC & David Maciejak - Please do not use in military or secret service organizations, or for illegal purposes (this is non-binding, these *** ignore laws and ethics anyway).

Hydra (https://github.com/vanhauser-thc/thc-hydra) starting at 2024-08-02 22:16:14
[INFO] Reduced number of tasks to 4 (mysql does not like many parallel connections)
[WARNING] Restorefile (you have 10 seconds to abort... (use option -I to skip waiting)) from a previous session found, to prevent overwriting, ./hydra.restore
[DATA] max 4 tasks per 1 server, overall 4 tasks, 10000 login tries (l:1/p:10000), ~2500 tries per task
[DATA] attacking mysql://172.30.0.5:3306/
[3306][mysql] host: 172.30.0.5   login: toor   password: summer
1 of 1 target successfully completed, 1 valid password found
[WARNING] Writing restore file because 1 final worker threads did not complete until end.
[ERROR] 1 target did not resolve or could not be connected
[ERROR] 0 target did not complete
Hydra (https://github.com/vanhauser-thc/thc-hydra) finished at 2024-08-02 22:16:26
red@machine:~$
```

What webserver software is running on web?
Does scanning the DC show you the name of the domain?
Try the -sC option with nmap on the windows 10. What is this option?
Try to SSH (using vagrant/vagrant) from red to another machine. Is this possible?

## Network Segmentation

As you can see, a hacker on this host-only network, has no restrictions to interact with the other machines. This is not a best-practice! A way to resolve this issue, is using network segmentation. By dividing the network in several segments and properly configuring the access to and from these subnets you can reduce the attack vector a lot.

- What is meant with the term "attack vector"?
  - Attack vector refers to the method or pathway that an attacker uses to gain unauthorized access to a network or system. Attack vectors can include various techniques such as phishing, malware, exploiting vulnerabilities, social engineering, and more.

- Is there already network segmentation done on the company network? Yes
  - Internal "company" 172.123.0.0/16
  - Host-Only Ethernet Adapter #2 192.168.100.0/24 (fake internet)
  - NAT 10.0.2.0/24 (real internet, through host)
  - The company internal network will be segmented into a DMZ, a server- and client zone.

- Remember what a DMZ is? What machines would be in the DMZ in this environment?
  - Only the webserver (172.30.20.10/24)

- What could be a disadvantage of using network segmentation in this case? Tip: win10 <-> dc interaction.
  - increased complexity (eg. routing, firewall rules)

**Configure the environment**, and especially **companyrouter**, to make sure that the red machine is not able to interact with most systems anymore. The only requirements that are left for the red machine are:

Browsing to <http://www.insecure.cyb> should work. Note: you are allowed to manually add a DNS entry to the red machine to tell the system how to resolve "<www.insecure.cyb>". Do be mindful why this is needed!

- Add DNS Entry on Red Machine:
  - Add the following line to the /etc/hosts : `172.30.20.10 www.insecure.cyb`.
- Let Red Machine through to the webserver

```bash
sudo iptables -A FORWARD -p tcp --dport 80 -s 192.168.100.102 -d 172.30.20.10 -j ACCEPT
# Block all other traffic from the red machine
sudo iptables -A FORWARD -s 192.168.100.102 -j DROP
```

All machines in the company network should still have internet access

- Ensure that NAT is configured to allow internet access for the internal segments (if not already configured).

```bash
# Masquerade traffic from internal networks to the internet
sudo iptables -t nat -A POSTROUTING -o eth0 -s 172.30.0.0/24 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -o eth0 -s 172.30.20.0/24 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -o eth0 -s 172.30.100.0/24 -j MASQUERADE
```

You should verify what functionality you might lose implementing the network segmentation.

- Ensure that the red machine can access http://www.insecure.cyb:
  - `curl http://www.insecure.cyb`
- Verify that other types of traffic (e.g., ping, SSH) from the red machine are blocked:
  - `ping 172.30.0.4`
  - `ssh 172.30.0.4`
- Verify that machines in the Servers zone, DMZ zone, and Clients zone have internet access:
  - `ping 8.8.8.8`
  - `curl http://example.com`

List out and create an overview of the advantages and disadvantages.

- Advantages:
  - Reduced attack surface
  - Increased security
  - Better control over network traffic
- Disadvantages:
  - Increased complexity
  - Increased management overhead
  - Increased cost

You should be able to revert back easily: Create proper documentation!

```bash
# REMOVE NAT RULES ON COMPANYROUTER
sudo iptables -t nat -D POSTROUTING -o eth0 -s 172.30.0.0/24 -j MASQUERADE
sudo iptables -t nat -D POSTROUTING -o eth0 -s 172.30.20.0/24 -j MASQUERADE
sudo iptables -t nat -D POSTROUTING -o eth0 -s 172.30.100.0/24 -j MASQUERADE
```

## Firewall

You are free to choose how you will implement this but be sure to be able to explain your reasoning. Document everything properly before making changes to existing configuration files. We suggest to use your knowledge of virtualbox as well. The goal of this exercise is to configure companyrouter as a firewall. Software that can help is for example firewall-cmd, iptables or nftables.

### Planning the Firewall Rules

Objectives:

- Restrict the red machine's access
  - Allow only HTTP traffic to <www.insecure.cyb> (172.30.20.10).
Block all other traffic from the red machine (192.168.100.102).
- Ensure all other machines retain internet access and can communicate with each other if needed.
  - WinClient needs to communicate with the webserver. But cant't communicate with the database.
  - Webserver needs to communicate with the database. and can be accessed by winclient and red machine
  - red machine can only access the webserver.
  - dc can communicate with all servers on the internal network (so server zone, dmz zone and client zone).
  - isprouter can communicate with companyrouter and can thus grant all machines internet access. (so all machines can ping isprouter I guess? or is this not needed?)
  - Use NAT to allow internal networks to access the internet.
  - 

Backup the current iptables configuration:

```bash
sudo iptables-save > /home/vagrant/iptables.backup
```

### Implementing the Firewall Rules