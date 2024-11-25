# Lab04

## SSH Port Forwarding

Being able to forward ports over SSH is a very important skill to have in cybersecurity both for red, purple and blue team activities. Figure out a way to perform SSH port forwarding to open a port (we suggest the same) on the router that connects back to the database server. In other words, by using SSH someone from the fake internet can reach the database although a direct connection to the database is blocked by the firewall. You do not have to make this persistent!

### Questions

- Why is this an interesting approach from a security pointof-view?
  - SSH Port Forwarding allows secure access to services behind a firewall or NAT without exposing them to the internet.
- When would you use local port forwarding?
  - Local port forwarding (-L) is used when you want to access a service on a remote server from your local machine.
- When would you use remote port forwarding?
  - Remote port forwarding (-R) is used when you want to allow a remote server to access a service on your local machine.
- Which of the two are more "common" in security?
  - Local port forwarding is more common in security. (system administrators, developers, penetration testers want to securely connect to services behind a firewall)
- Some people call SSH port forwarding also a "poor man's VPN". Why?
  - It provides a way to tunnel traffic securely between hosts without the complexity of setting up a full VPN.

### You can find some visual guides here

<https://unix.stackexchange.com/questions/115897/whats-ssh-port-forwarding-and-whats-the-difference-between-ssh-local-and-remot>
<https://iximiuz.com/en/posts/ssh-tunnels/>

### At this point we expect that you

- can SSH in every machine from your laptop, even with the firewall on, by using the company router as an SSH bastion. What do you need to configure on the firewall to do this? By using SSH, you will save a lot of time on the exam and during labs (you can copy-paste, scroll through output, ...). Use the VirtualBox window only if you really have to.
  - ✅
- use SSH keys everywhere (preferably, password authentication is disabled).
  - ✅
  - Edit SSH Configuration file to disable password authentication

    ```bash
    sudo nano /etc/ssh/sshd_config
    # Or the following config file if needed (eg. companyrouter)
    sudo vi /etc/ssh/sshd_config.d/50-redhat.conf
    ```

    - Change `PasswordAuthentication yes` to `PasswordAuthentication no`
    - Restart SSH service

    ```bash
    sudo systemctl restart sshd
    ```

  - Remove Passphrase from SSH Key (Optional)

    ```bash
    ssh-keygen -p -f ~/.ssh/id_rsa
    ```

- can use SSH tunneling to reach all services on internal networks, even with the firewall on. You know how the -L and -R option work, and how they differ.
  - Example 1: use port forwarding to get to see the webpage from the webserver in the browser on the host (your laptop).
    - `ssh -L [local_port]:[remote_host]:[remote_port] [ssh_server]`
    - `ssh -L 8080:172.30.20.10:80 cyb@companyrouter`
  - Example 2: use port forwarding to access the database from the host (your laptop).
    - `ssh -R [remote_port]:[local_host]:[local_port] [ssh_server]`
    - `ssh -L 3307:172.30.0.5:3306 cyb@companyrouter`
  - Example 3: combine both examples in a single command so you can see the webpage and access the database both at the same time from the host (your laptop).
    - `ssh -J [jump_host] [target_host]`
    - `ssh -L 8080:172.30.20.10:80 -L 3307:172.30.0.5:3306 cyb@companyrouter`
- can use the -J option. Example: try to log in on web from the host (your laptop).
  
  ```powershell
  PS C:\Users\JensV> ssh -J cyb@companyrouter cyb@172.30.0.5
  Last login: Wed Aug  7 14:40:12 2024 from 172.30.0.254
  [cyb@database ~]$
  ```

## IDS/IPS

Note: Disable the firewall configuration from the previous lab(s) to avoid confusion. Focus on the IDS/IPS configuration separately. As mentioned in step 2, Suricata requires extra memory, so tune your memory configuration of the companyrouter to at least 4GB of memory for this lab.

One of the topics that came up when Walt was still around was the idea of setting up an IDS and/or IPS system using the Suricata software: <https://suricata.io/> .

Another common used tool is snort. Suricata uses the same rules as snort so that might be an interesting tip when searching the web for help.

1. Ask yourself which system (or systems) in the network layout of the company would be best suited to install IDS/IPS software on. Revert back to the original network diagram of the initial setup and answer the same questions as well.
   - What traffic can be seen?
   - What traffic (if any) will be missed and when?

2. For this exercise, disable the firewall so that you can reach the database. Install tcpdump on the machine where you will install Suricata on and increase the memory (temporary if needed) to at least 4GB. Reboot if necessary.

   - Op **Companyrouter** zal Suricata geïnstalleerd worden. Deze kan alle traffic zien dat hij route. Van **red** naar **web** en **database** kan **companyrouter** traffic zien, tussen **web** en **database** niet omdat dit niet geroute moet worden (zelfde subnet).

   ```bash
    sudo systemctl stop firewalld
    sudo systemctl disable firewalld

    sudo dnf install tcpdump -y
    sudo dnf install epel-release -y
    sudo dnf update -y
    sudo dnf install suricata -y

    sudo reboot
    ```

3. Verify that you see packets (in tcpdump) from red to the database. Try this by issuing a ping and by using the hydra mysql attack as seen previously. Are you able to see this traffic in tcpdump? What about a ping between the webserver and the database?
   - Bij het pingen van de database vanaf **red** kan je zien dat de ping requests en replies worden verstuurd en ontvangen.
   - Bij het pingen van de database vanaf **web** kan je hetzelfde zien. Dit komt omdat ik het verkeer ook eerst via companyrouter heb laten leiden. Web zit in de DMZ Zone, de database in de server zone. Het verkeer tussen DC en Database wordt niet geroute door companyrouter. 

  ```bash
  red@machine:~$ ping 172.30.0.5 -c4
  PING 172.30.0.5 (172.30.0.5) 56(84) bytes of data.
  64 bytes from 172.30.0.5: icmp_seq=1 ttl=63 time=0.690 ms
  64 bytes from 172.30.0.5: icmp_seq=2 ttl=63 time=2.62 ms
  64 bytes from 172.30.0.5: icmp_seq=3 ttl=63 time=0.558 ms
  64 bytes from 172.30.0.5: icmp_seq=4 ttl=63 time=2.45 ms

  --- 172.30.0.5 ping statistics ---
  4 packets transmitted, 4 received, 0% packet loss, time 3016ms
  rtt min/avg/max/mdev = 0.558/1.577/2.616/0.956 ms

  [cyb@companyrouter ~]$ sudo tcpdump -i eth1
  dropped privs to tcpdump
  tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
  listening on eth1, link-type EN10MB (Ethernet), snapshot length 262144 bytes
  11:56:03.163579 IP 192.168.100.102 > 172.30.0.5: ICMP echo request, id 17528, seq 1, length 64
  11:56:03.163868 IP 172.30.0.5 > 192.168.100.102: ICMP echo reply, id 17528, seq 1, length 64
  11:56:04.165915 IP 192.168.100.102 > 172.30.0.5: ICMP echo request, id 17528, seq 2, length 64
  11:56:04.167067 IP 172.30.0.5 > 192.168.100.102: ICMP echo reply, id 17528, seq 2, length 64
  11:56:05.167030 IP 192.168.100.102 > 172.30.0.5: ICMP echo request, id 17528, seq 3, length 64
  11:56:05.167259 IP 172.30.0.5 > 192.168.100.102: ICMP echo reply, id 17528, seq 3, length 64
  11:56:06.180365 IP 192.168.100.102 > 172.30.0.5: ICMP echo request, id 17528, seq 4, length 64
  11:56:06.181522 IP 172.30.0.5 > 192.168.100.102: ICMP echo reply, id 17528, seq 4, length 64
  11:56:08.243180 ARP, Request who-has 172.30.0.5 tell companyrouter, length 28
  11:56:08.244366 ARP, Reply 172.30.0.5 is-at 08:00:27:85:77:8b (oui Unknown), length 46
  11:56:08.333035 ARP, Request who-has companyrouter tell 172.30.0.5, length 46
  11:56:08.333064 ARP, Reply companyrouter is-at 08:00:27:9c:fb:15 (oui Unknown), length 28
  ```

4. Install and configure the Suricata software. Keep it simple and stick to the default configuration file(s) as much as possible. Change the interface to the one you want to sniff on in the correct Suricata configuration file. Focus on 1 interface when starting out!

5. Create your own alert rules.

   - What is the difference between the fast.log and the eve.json files?
     - `fast.log`: Dit bestand bevat korte, eenvoudige meldingen van gedetecteerde events. Het is makkelijk leesbaar en ideaal voor snelle analyse.
     - `eve.json`: Dit is een gedetailleerd logbestand in JSON-formaat. Het bevat uitgebreide informatie over elk event, inclusief metadata.
   - Create a rule that alerts as soon as a ping is performed between two machines (for example red and database)
     - Maak een file aan  `/etc/suricata/rules/local.rules`

      ```bash
      alert icmp any any -> any any (msg:"ICMP Ping detected"; sid:1000001; rev:1;)
      alert tcp any any -> any 3306 (msg:"MySQL Connection Detected"; sid:1000002; rev:1;)
      ```

     - In `/etc/suricata/suricata.yaml` pas het volgende aan:

      ```bash
      default-rule-path: /etc/suricata/rules
      
      rule-files:
        - local.rules
      ```

     - Ping de database vanaf de red machine, gebruik onderste commando om na te gaan of de pings gedetecteerd worden.

      ```bash
      [cyb@companyrouter ~]$ sudo cat /var/log/suricata/fast.log
      08/09/2024-08:39:15.533675  [**] [1:1000001:1] ICMP Ping detected [**] [Classification: (null)] [Priority: 3] {ICMP} 192.168.100.102:8 -> 172.30.0.5:0
      08/09/2024-08:39:15.534501  [**] [1:1000001:1] ICMP Ping detected [**] [Classification: (null)] [Priority: 3] {ICMP} 172.30.0.5:0 -> 192.168.100.102:0 
      ```

   - Test your out-of-the-box configuration and browse on your red machine to <insecure.cyb/cmd> and enter "id" as an evil command. Does it trigger an alert? If not are you able to make it trigger an alert?
     - Aangezien red machine een CLI is, heb ik volgend curl commando opgesteld

      ```bash
      curl -X POST http://insecure.cyb:8000/exec \
          -H "Content-Type: application/json" \
          -d '{"cmd":"id"}'

      red@machine:~$ curl -X POST http://insecure.cyb:8000/exec \
          -H "Content-Type: application/json" \
          -d '{"cmd":"id"}'
      {"output":"uid=0(root) gid=0(root) groups=0(root) context=system_u:system_r:unconfined_service_t:s0\n"}

      red@machine:~$ curl -X POST http://insecure.cyb:8000/exec -H "Content-Type: application/json" -d '{"cmd":"ls"}'
      {"output":"afs\nbin\nboot\ndev\netc\nhome\nlib\nlib64\nmedia\nmnt\nopt\nproc\nroot\nrun\nsbin\nsrv\nsys\ntmp\nusr\nvagrant\nvar\n"}
      ```

   - Create an alert that checks the mysql tcp port and rerun a hydra attack to check this rule. Can you visually see this bruteforce attack in the fast.log file? Tip: monitor the file live with an option of tail.
      - Pas aan in `/etc/suricata/rules/local.rules`

      ```bash
      alert icmp any any -> any any (msg:"ICMP Ping detected"; sid:1000001; rev:1;)
      alert tcp any any -> any 3306 (msg:"MySQL Connection Detected"; sid:1000002; rev:1;)
      ```

      ```bash
        08/09/2024-08:40:42.168301  [**] [1:1000002:1] MySQL Connection Detected [**] [Classification: (null)] [Priority: 3] {TCP} 192.168.100.102:42652 -> 172.30.0.5:3306
        08/09/2024-08:40:42.168302  [**] [1:1000002:1] MySQL Connection Detected [**] [Classification: (null)] [Priority: 3] {TCP} 192.168.100.102:42628 -> 172.30.0.5:3306
        08/09/2024-08:40:42.168549  [**] [1:1000002:1] MySQL Connection Detected [**] [Classification: (null)] [Priority: 3] {TCP} 192.168.100.102:42654 -> 172.30.0.5:3306
        08/09/2024-08:40:46.083746  [**] [1:1000002:1] MySQL Connection Detected [**] [Classification: (null)] [Priority: 3] {TCP} 192.168.100.102:43080 -> 172.30.0.5:3306
      ```

   - Go have a look at the Suricata documentation. What is the default configuration of Suricata, is it an IPS or IDS?
     - It is an IDS by default. To enable IPS, you need to change the mode to `autofp` in the configuration file.
   - What do you have to change to the setup to switch to the other (IPS or IDS)? You are free to experiment more and go all out with variables (for the networks) and rules. Make sure you can conceptually explain why certain rules would be useful and where (= from which subnet to which subnet) they should be applied?
      - Change the Mode to Inline

      ```yaml
      af-packet:
        - interface: eth0  # or the interface you want to monitor
          threads: auto
          cluster-id: 99
          cluster-type: cluster_flow
          defrag: yes
          copy-mode: ips
          copy-iface: eth0  # This specifies that the interface is used in inline mode
      ```

      - Restart suricata `sudo systemctl restart suricata`.

6. To illustrate the difference between an IPS and firewall, enable the firewall and redo the hydra attack through an SSH tunnel. Can you make sure that Suricata detects this attack as an IPS? Do you understand why Suricata can offer this protection whilst a firewall cannot? What is the difference between an IPS and firewall? On which layers of the OSI-model do they work?
   - Firewall:
     - Layer: Operates mainly at OSI layers 3 and 4 (Network and Transport layers).
     - Function: Filters traffic based on IP addresses, ports, and protocols. It decides whether to allow or block traffic based on predefined rules.
   - Intrusion Prevention System (IPS)
     - Layer: Operates at OSI layers 3 to 7 (Network to Application layers)
     - Function: Monitors traffic in real-time and can take action (such as dropping packets) if traffic matches known attack signatures or behaviors. It detects attacks that could bypass simple firewalls
   - Why Suricata (IPS) Can Offer Protection While a Firewall Cannot:
     - A firewall might allow traffic based on IP and port, but an IPS can detect and block malicious patterns within the allowed traffic, such as SQL injection or buffer overflow attempts that the firewall wouldn’t catch

If needed, bring the memory back down from the machine running Suricata and disable the systemd service for future labs.



## Output from fake environment

```bash
[cyb@companyrouter ~]: ls -ali
d-wxrw--wt 1 4357 4357 4096 2024-08-10 13:27 .
drwxr-xr-x 1 root root 4096 2013-04-05 12:02 ..
[cyb@companyrouter ~]: cat /etc/passwd
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/bin/sh
bin:x:2:2:bin:/bin:/bin/sh
sys:x:3:3:sys:/dev:/bin/sh
sync:x:4:65534:sync:/bin:/bin/sync
games:x:5:60:games:/usr/games:/bin/sh
man:x:6:12:man:/var/cache/man:/bin/sh
lp:x:7:7:lp:/var/spool/lpd:/bin/sh
mail:x:8:8:mail:/var/mail:/bin/sh
news:x:9:9:news:/var/spool/news:/bin/sh
uucp:x:10:10:uucp:/var/spool/uucp:/bin/sh
proxy:x:13:13:proxy:/bin:/bin/sh
www-data:x:33:33:www-data:/var/www:/bin/sh
backup:x:34:34:backup:/var/backups:/bin/sh
list:x:38:38:Mailing List Manager:/var/list:/bin/sh
irc:x:39:39:ircd:/var/run/ircd:/bin/sh
gnats:x:41:41:Gnats Bug-Reporting System (admin):/var/lib/gnats:/bin/sh
nobody:x:65534:65534:nobody:/nonexistent:/bin/sh
libuuid:x:100:101::/var/lib/libuuid:/bin/sh
sshd:x:101:65534::/var/run/sshd:/usr/sbin/nologin
phil:x:1000:1000:Phil California,,,:/home/phil:/bin/bash
[cyb@companyrouter ~]: echo "Test content" > testfile.txt
[cyb@companyrouter ~]: ping google.com -c4
PING google.com (29.89.32.244) 56(84) bytes of data.
64 bytes from google.com (29.89.32.244): icmp_seq=1 ttl=50 time=46.5 ms
64 bytes from google.com (29.89.32.244): icmp_seq=2 ttl=50 time=42.7 ms
64 bytes from google.com (29.89.32.244): icmp_seq=3 ttl=50 time=45.4 ms
64 bytes from google.com (29.89.32.244): icmp_seq=4 ttl=50 time=40.7 ms

--- google.com ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 907ms
rtt min/avg/max/mdev = 48.264/50.352/52.441/2.100 ms
[cyb@companyrouter ~]: netstat -tuln
Active Internet connections (w/o servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State
tcp        0      0 *:ssh                   *:*                     LISTEN
tcp6       0      0 [::]:ssh                [::]:*                  LISTEN
Active UNIX domain sockets (only servers)
Proto RefCnt Flags       Type       State         I-Node   Path
unix  2      [ ACC ]     STREAM     LISTENING     8969     /var/run/acpid.socket
unix  2      [ ACC ]     STREAM     LISTENING     6807     @/com/ubuntu/upstart
unix  2      [ ACC ]     STREAM     LISTENING     7299     /var/run/dbus/system_bus_socket
unix  2      [ ACC ]     SEQPACKET  LISTENING     7159     /run/udev/control
[cyb@companyrouter ~]: uname -a
Linux cyb 3.2.0-4-amd64 #1 SMP Debian 3.2.68-1+deb7u1 x86_64 GNU/Linux
[cyb@companyrouter ~]: df -h
Filesystem                                              Size  Used Avail Use% Mounted on
rootfs                                                  4.7G  731M  3.8G  17% /
udev                                                     10M     0   10M   0% /dev
tmpfs                                                    25M  192K   25M   1% /run
/dev/disk/by-uuid/65626fdc-e4c5-4539-8745-edc212b9b0af  4.7G  731M  3.8G  17% /
tmpfs                                                   5.0M     0  5.0M   0% /run/lock
tmpfs                                                   101M     0  101M   0% /run/shm
```
