# Lab03

Walt, the system administrator of the company is sick and will be for a long time. He has left some notes for you. Take extra care as he has written down some todo's both as mental notes for himself as for you.

## DHCP

The companyrouter should also be a DHCP server. **TODO**: check configuration and rethink network-layout for network segmentation/ firewalling

In `/etc/dhcp/dhcpd.conf`

```bash
# dhcpd.conf
#
# Sample configuration file for ISC dhcpd
#
# option definitions common to all supported networks...
option domain-name "insecure.cyb";
option domain-name-servers 172.30.0.4;

default-lease-time 600;
max-lease-time 7200;

# Use this to enble / disable dynamic dns updates globally.
#ddns-update-style none;

# If this DHCP server is the official DHCP server for the local
# network, the authoritative directive should be uncommented.
authoritative;

# Use this to send dhcp log messages to a different log file (you also
# have to hack syslog.conf to complete the redirection).
log-facility local7;

subnet 172.30.0.0 netmask 255.255.255.0 {
  range 172.30.0.10 172.30.0.200;
  option routers 172.30.0.254;
}

subnet 172.30.20.0 netmask 255.255.255.0 {
  range 172.30.20.10 172.30.20.200;
  option routers 172.30.20.254;
}

subnet 172.30.100.0 netmask 255.255.255.0 {
  range 172.30.100.10 172.30.100.200;
  option routers 172.30.100.254;
}

subnet 192.168.100.0 netmask 255.255.255.0 {
  range 192.168.100.7 192.168.100.200;
  option routers 192.168.100.253;
}
```

## Conclusion after external meeting with secure.xyz

- Make sure to perform network segmentation
- Implement routes(= all machines should be able to access each other on layer 3)
- Configure firewall rules to default block all protocols and ports
- Only allow specific ports: **TODO**: check which ports/services

### Open Ports (**see OpenL3Ports.md**)

- Companyrouter (4 Adapters)
  - UDP: 67 (DHCP), 111 (RPC), 323 (NTP)
  - TCP: 22 (SSH), 111 (RPC)
- ISPRouter (192.168.100.254)
  - TCP: 22 (SSH)
  - UDP: 67 (DHCP)
- Database (172.30.0.5/24)
  - UDP: 111 (RPC), 323 (NTP)
  - TCP: 22 (SSH), 111 (RPC), 3306 (MySQL), 33060 (MySQLX)
- Webserver (172.30.20.10/24)
  - UDP: 111 (RPC), 323 (NTP)
  - TCP: 22 (SSH), 80 (HTTP), 111 (RPC), 8000 (Custom/Java App)
- DC (172.30.0.4/24)
  - TCP: Multiple ports including 22 (SSH), 88 (Kerberos), 135 (RPC), 389 (LDAP), 445 (SMB), 464 (Kerberos), 593 (RPC), 636 (LDAPS), 3268 (LDAP), 3269 (LDAPS), 3389 (RDP), 5985 (WinRM), 9389 (AD Web Services), 53 (DNS)

### Implement iptables rules (Beginning)

```bash
# Backup current iptables rules
sudo iptables-save > /home/vagrant/iptables.backup

# Flush all rules
sudo iptables -F
sudo iptables -t nat -F

# Default policies to drop all traffic
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT

# Allow Loopback interface traffic
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT

# Allow Established and Related Incoming Connections
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
```

### Allow specific ports only

**Companyrouter**:

```bash
# SSH
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# DHCP
sudo iptables -A INPUT -p udp --dport 67 -j ACCEPT

# RPC
sudo iptables -A INPUT -p udp --dport 111 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 111 -j ACCEPT

# NTP
sudo iptables -A INPUT -p udp --dport 323 -j ACCEPT
```

**ISPRouter**:

```bash
# SSH
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# DHCP
sudo iptables -A INPUT -p udp --dport 67 -j ACCEPT
```

**Database**:

```bash
# SSH
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# RPC
sudo iptables -A INPUT -p udp --dport 111 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 111 -j ACCEPT

# NTP
sudo iptables -A INPUT -p udp --dport 323 -j ACCEPT

# MySQL
sudo iptables -A INPUT -p tcp --dport 3306 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 33060 -j ACCEPT
```

**Webserver**:

```bash
# SSH
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# HTTP
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# RPC
sudo iptables -A INPUT -p udp --dport 111 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 111 -j ACCEPT

# NTP
sudo iptables -A INPUT -p udp --dport 323 -j ACCEPT

# Custom Java App
sudo iptables -A INPUT -p tcp --dport 8000 -j ACCEPT
```

**DC**:

```bash
# SSH
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Kerberos
sudo iptables -A INPUT -p tcp --dport 88 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 88 -j ACCEPT

# RPC
sudo iptables -A INPUT -p tcp --dport 135 -j ACCEPT

# LDAP
sudo iptables -A INPUT -p tcp --dport 389 -j ACCEPT

# SMB
sudo iptables -A INPUT -p tcp --dport 445 -j ACCEPT

# Kerberos Password Change
sudo iptables -A INPUT -p tcp --dport 464 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 464 -j ACCEPT

# RPC over HTTP
sudo iptables -A INPUT -p tcp --dport 593 -j ACCEPT

# LDAPS
sudo iptables -A INPUT -p tcp --dport 636 -j ACCEPT

# Global Catalog
sudo iptables -A INPUT -p tcp --dport 3268 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 3269 -j ACCEPT

# RDP
sudo iptables -A INPUT -p tcp --dport 3389 -j ACCEPT

# WinRM
sudo iptables -A INPUT -p tcp --dport 5985 -j ACCEPT

# AD Web Services
sudo iptables -A INPUT -p tcp --dport 9389 -j ACCEPT

# DNS
sudo iptables -A INPUT -p tcp --dport 53 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 53 -j ACCEPT
```

### Configure NAT for Internet Access

```bash
sudo iptables -t nat -A POSTROUTING -o eth0 -s 172.30.0.0/24 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -o eth0 -s 172.30.20.0/24 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -o eth0 -s 172.30.100.0/24 -j MASQUERADE
```

### Save current iptables rules

```bash
sudo iptables-save | sudo tee /etc/iptables/rules.v4
```

### Credentials on website to connect to the database

The database server runs mysql. The developers of the websites have let me know they used other credentials on a feature on the webserver that requires mysql. My own credentials are root/summer but TODO: check which credentials they used on the website to connect to the database

In `/var/www/html/index.php` the following credentials are used:

```php
    // Define your database credentials
    $servername = "172.30.0.5";
    $username = "sammy";
    $password = "FLAG-741852";
    $database = "users";
```

### Webserver

The webserver runs apache to host the main <www.insecure.cybwebsite>.

The webserver also acts as a reverse proxy for another (java-application). The app can be viewed by browsing to <www.insecure.cyb/cmd>. The java application is configured with a systemd service. **TODO**: double check this configuration and how it is properly configured.

```bash
[cyb@web ~]$ sudo ls /etc/httpd/conf.modules.d/
00-base.conf      00-lua.conf       00-proxy.conf     10-h2.conf
00-brotli.conf    00-mpm.conf       00-systemd.conf   10-proxy_h2.conf
00-dav.conf       00-optional.conf  01-cgi.conf       README
[cyb@web ~]$ sudo ls /etc/httpd/conf.d/
README             insecure.cyb.conf  userdir.conf
autoindex.conf     php.conf           welcome.conf
```

Added the following to `/etc/httpd/conf.d/insecure.cyb.conf` to configure the reverse proxy:

```bash
<VirtualHost *:80>
    ServerName insecure.cyb
    DocumentRoot /var/www/html
    <Directory /var/www/html>
        AllowOverride All
        Require all granted
    </Directory>

    # Reverse Proxy Configuration
    ProxyRequests Off
    ProxyPass /cmd http://localhost:8080/cmd
    ProxyPassReverse /cmd http://localhost:8080/cmd

    ErrorLog /var/log/httpd/insecure.cyb-error.log
    CustomLog /var/log/httpd/insecure.cyb-access.log combined
</VirtualHost>
```

Check if the service is running:

```bash
[cyb@web ~]$ sudo systemctl status httpd
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; preset: disabled)
    Drop-In: /usr/lib/systemd/system/httpd.service.d
             └─php-fpm.conf
     Active: active (running) since Mon 2024-08-05 12:22:00 UTC; 24min ago
       Docs: man:httpd.service(8)
   Main PID: 1946 (httpd)
     Status: "Total requests: 2; Idle/Busy workers 100/0;Requests/sec: 0.00135; Bytes served/sec:  >
      Tasks: 213 (limit: 2262)
     Memory: 17.0M
        CPU: 1.017s
     CGroup: /system.slice/httpd.service
             ├─1946 /usr/sbin/httpd -DFOREGROUND
             ├─1947 /usr/sbin/httpd -DFOREGROUND
             ├─1948 /usr/sbin/httpd -DFOREGROUND
             ├─1949 /usr/sbin/httpd -DFOREGROUND
             └─1950 /usr/sbin/httpd -DFOREGROUND

Aug 05 12:22:00 web systemd[1]: Starting The Apache HTTP Server...
Aug 05 12:22:00 web httpd[1946]: [Mon Aug 05 12:22:00.786448 2024] [so:warn] [pid 1946:tid 1946] AH>
Aug 05 12:22:00 web httpd[1946]: [Mon Aug 05 12:22:00.787573 2024] [so:warn] [pid 1946:tid 1946] AH>
Aug 05 12:22:00 web httpd[1946]: AH00558: httpd: Could not reliably determine the server's fully qu>
Aug 05 12:22:00 web systemd[1]: Started The Apache HTTP Server.
Aug 05 12:22:00 web httpd[1946]: Server configured, listening on: port 80
[cyb@web ~]$ sudo systemctl status insecurewebapp.service
● insecurewebapp.service - start script for insecurewebapp
     Loaded: loaded (/etc/systemd/system/insecurewebapp.service; enabled; preset: disabled)
     Active: active (running) since Mon 2024-08-05 08:45:45 UTC; 4h 1min ago
   Main PID: 668 (java)
      Tasks: 20 (limit: 2262)
     Memory: 93.0M
        CPU: 17.188s
     CGroup: /system.slice/insecurewebapp.service
             └─668 /usr/bin/java -server -Xms128m -Xmx512m -jar /opt/insecurewebapp/app.jar

Aug 05 08:45:52 web insecurewebapp[668]: Aug 05, 2024 8:45:51 AM be.programming101.dt.web.WebServer>
Aug 05 08:45:52 web insecurewebapp[668]: INFO: Server is listening on port: 8,000
Aug 05 08:45:52 web insecurewebapp[668]: Aug 05, 2024 8:45:51 AM io.vertx.core.impl.launcher.comman>
Aug 05 08:45:52 web insecurewebapp[668]: INFO: Succeeded in deploying verticle
Aug 05 08:48:32 web insecurewebapp[668]: Aug 05, 2024 8:48:32 AM be.programming101.dt.web.WebApp log
Aug 05 08:48:32 web insecurewebapp[668]: INFO: http://insecure.cyb:8000/favicon.ico
Aug 05 12:08:29 web insecurewebapp[668]: Aug 05, 2024 12:08:29 PM be.programming101.dt.web.WebApp l>
Aug 05 12:08:29 web insecurewebapp[668]: INFO: http://insecure.cyb:8000/favicon.ico
Aug 05 12:22:11 web insecurewebapp[668]: Aug 05, 2024 12:22:11 PM be.programming101.dt.web.WebApp l>
Aug 05 12:22:11 web insecurewebapp[668]: INFO: http://insecure.cyb:8000/


[cyb@web ~]$ sudo tail -f /var/log/httpd/insecure.cyb-access.log
172.30.100.100 - - [04/Aug/2024:19:36:22 +0000] "GET /favicon.ico HTTP/1.1" 404 196 "http://insecure.cyb/" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36 Edg/127.0.0.0"
172.30.100.100 - - [04/Aug/2024:19:36:28 +0000] "GET /favicon.ico HTTP/1.1" 404 196 "http://172.30.20.10/" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36 Edg/127.0.0.0"
172.30.100.100 - - [05/Aug/2024:08:48:34 +0000] "GET /favicon.ico HTTP/1.1" 404 196 "http://insecure.cyb/" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36 Edg/127.0.0.0"
172.30.100.100 - - [05/Aug/2024:09:02:20 +0000] "GET /favicon.ico HTTP/1.1" 404 196 "http://insecure.cyb/" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36 Edg/127.0.0.0"

# Check error logs if needed
[cyb@web ~]$ sudo tail -f /var/log/httpd/insecure.cyb-error.log

# Check the service logs
[cyb@web ~]$ sudo journalctl -u insecurewebapp.service -f
```

### Active Directory Users

There is a Windows Active Directory domain (insecure.cyb) created. Win10 is a Windows 10 machine and is domain joined. All AD users (see below) should be able to login on the domain.

If necessary, you can use my (Walt) credentials: Username: Walt; Password: ***Friday13th!***

**TODO**: I lost access to some systems, please create a walt user with the above password if there is no walt user and update my password if the password is not correct.

```powershell
# Walt User exists
PS C:\Users\cyb-dc.insecure> Get-ADUser -Identity Walt


DistinguishedName : CN=Walt Disney,CN=Users,DC=insecure,DC=cyb
Enabled           : True
GivenName         : walt
Name              : Walt Disney
ObjectClass       : user
ObjectGUID        : 34249e91-0e39-4388-bf0a-023f3b6244fc
SamAccountName    : walt
SID               : S-1-5-21-2681222979-3123228727-1689025860-1105
Surname           : Disney
UserPrincipalName :

# If the user does not exist, create it (WIP)
New-ADUser -Name "Walt" -GivenName "Walt" -Surname "Admin" -SamAccountName "Walt" -UserPrincipalName "Walt@insecure.cyb" -Path "CN=Users,DC=insecure,DC=cyb" -AccountPassword (ConvertTo-SecureString "Friday13th!" -AsPlainText -Force) -Enabled $true

# Change password to Friday13th! if needed
PS C:\Users\cyb-dc.insecure> Set-ADAccountPassword -Identity "Walt" -NewPassword (ConvertTo-SecureString "Friday13th!" -AsPlainText -Force)
```

#### OU's

```powershell
PS C:\Users\cyb-dc.insecure> Get-ADOrganizationalUnit -Filter * | Select-Object Name, DistinguishedName

Name               DistinguishedName
----               -----------------
Domain Controllers OU=Domain Controllers,DC=insecure,DC=cyb
Disney             OU=Disney,DC=insecure,DC=cyb
Aladdin            OU=Aladdin,OU=Disney,DC=insecure,DC=cyb
LionKing           OU=LionKing,OU=Disney,DC=insecure,DC=cyb
```

#### Groups

```powershell
PS C:\Users\cyb-dc.insecure> Get-ADGroup -Filter * | Select-Object Name, DistinguishedName

Name                                    DistinguishedName
----                                    -----------------
Administrators                          CN=Administrators,CN=Builtin,DC=insecure,DC=cyb
Users                                   CN=Users,CN=Builtin,DC=insecure,DC=cyb
Guests                                  CN=Guests,CN=Builtin,DC=insecure,DC=cyb
Print Operators                         CN=Print Operators,CN=Builtin,DC=insecure,DC=cyb
Backup Operators                        CN=Backup Operators,CN=Builtin,DC=insecure,DC=cyb
Replicator                              CN=Replicator,CN=Builtin,DC=insecure,DC=cyb
Remote Desktop Users                    CN=Remote Desktop Users,CN=Builtin,DC=insecure,DC=cyb
Network Configuration Operators         CN=Network Configuration Operators,CN=Builtin,DC=insecure,DC=cyb
Performance Monitor Users               CN=Performance Monitor Users,CN=Builtin,DC=insecure,DC=cyb
Performance Log Users                   CN=Performance Log Users,CN=Builtin,DC=insecure,DC=cyb
Distributed COM Users                   CN=Distributed COM Users,CN=Builtin,DC=insecure,DC=cyb
IIS_IUSRS                               CN=IIS_IUSRS,CN=Builtin,DC=insecure,DC=cyb
Cryptographic Operators                 CN=Cryptographic Operators,CN=Builtin,DC=insecure,DC=cyb
Event Log Readers                       CN=Event Log Readers,CN=Builtin,DC=insecure,DC=cyb
Certificate Service DCOM Access         CN=Certificate Service DCOM Access,CN=Builtin,DC=insecure,DC=cyb
RDS Remote Access Servers               CN=RDS Remote Access Servers,CN=Builtin,DC=insecure,DC=cyb
RDS Endpoint Servers                    CN=RDS Endpoint Servers,CN=Builtin,DC=insecure,DC=cyb
RDS Management Servers                  CN=RDS Management Servers,CN=Builtin,DC=insecure,DC=cyb
Hyper-V Administrators                  CN=Hyper-V Administrators,CN=Builtin,DC=insecure,DC=cyb
Access Control Assistance Operators     CN=Access Control Assistance Operators,CN=Builtin,DC=insecure,DC=cyb
Remote Management Users                 CN=Remote Management Users,CN=Builtin,DC=insecure,DC=cyb
Storage Replica Administrators          CN=Storage Replica Administrators,CN=Builtin,DC=insecure,DC=cyb
Domain Computers                        CN=Domain Computers,CN=Users,DC=insecure,DC=cyb
Domain Controllers                      CN=Domain Controllers,CN=Users,DC=insecure,DC=cyb
Schema Admins                           CN=Schema Admins,CN=Users,DC=insecure,DC=cyb
Enterprise Admins                       CN=Enterprise Admins,CN=Users,DC=insecure,DC=cyb
Cert Publishers                         CN=Cert Publishers,CN=Users,DC=insecure,DC=cyb
Domain Admins                           CN=Domain Admins,CN=Users,DC=insecure,DC=cyb
Domain Users                            CN=Domain Users,CN=Users,DC=insecure,DC=cyb
Domain Guests                           CN=Domain Guests,CN=Users,DC=insecure,DC=cyb
Group Policy Creator Owners             CN=Group Policy Creator Owners,CN=Users,DC=insecure,DC=cyb
RAS and IAS Servers                     CN=RAS and IAS Servers,CN=Users,DC=insecure,DC=cyb
Server Operators                        CN=Server Operators,CN=Builtin,DC=insecure,DC=cyb
Account Operators                       CN=Account Operators,CN=Builtin,DC=insecure,DC=cyb
Pre-Windows 2000 Compatible Access      CN=Pre-Windows 2000 Compatible Access,CN=Builtin,DC=insecure,DC=cyb
Incoming Forest Trust Builders          CN=Incoming Forest Trust Builders,CN=Builtin,DC=insecure,DC=cyb
Windows Authorization Access Group      CN=Windows Authorization Access Group,CN=Builtin,DC=insecure,DC=cyb
Terminal Server License Servers         CN=Terminal Server License Servers,CN=Builtin,DC=insecure,DC=cyb
Allowed RODC Password Replication Group CN=Allowed RODC Password Replication Group,CN=Users,DC=insecure,DC=cyb
Denied RODC Password Replication Group  CN=Denied RODC Password Replication Group,CN=Users,DC=insecure,DC=cyb
Read-only Domain Controllers            CN=Read-only Domain Controllers,CN=Users,DC=insecure,DC=cyb
Enterprise Read-only Domain Controllers CN=Enterprise Read-only Domain Controllers,CN=Users,DC=insecure,DC=cyb
Cloneable Domain Controllers            CN=Cloneable Domain Controllers,CN=Users,DC=insecure,DC=cyb
Protected Users                         CN=Protected Users,CN=Users,DC=insecure,DC=cyb
Key Admins                              CN=Key Admins,CN=Users,DC=insecure,DC=cyb
Enterprise Key Admins                   CN=Enterprise Key Admins,CN=Users,DC=insecure,DC=cyb
DnsAdmins                               CN=DnsAdmins,CN=Users,DC=insecure,DC=cyb
DnsUpdateProxy                          CN=DnsUpdateProxy,CN=Users,DC=insecure,DC=cyb
agrabah                                 CN=agrabah,OU=Disney,DC=insecure,DC=cyb
pride lands                             CN=pride lands,OU=Disney,DC=insecure,DC=cyb
```

#### Users

```powershell
PS C:\Users\cyb-dc.insecure> Get-ADUser -Filter * | Select-Object Name, SamAccountName, DistinguishedName

Name          SamAccountName DistinguishedName
----          -------------- -----------------
Administrator Administrator  CN=Administrator,CN=Users,DC=insecure,DC=cyb
Guest         Guest          CN=Guest,CN=Users,DC=insecure,DC=cyb
vagrant       vagrant        CN=vagrant,CN=Users,DC=insecure,DC=cyb
krbtgt        krbtgt         CN=krbtgt,CN=Users,DC=insecure,DC=cyb
Walt Disney   walt           CN=Walt Disney,CN=Users,DC=insecure,DC=cyb
bdup          bdup           CN=bdup,CN=Users,DC=insecure,DC=cyb
Aladdin       Aladdin        CN=Aladdin,OU=Aladdin,OU=Disney,DC=insecure,DC=cyb
Jasmine       Jasmine        CN=Jasmine,OU=Aladdin,OU=Disney,DC=insecure,DC=cyb
Genie         Genie          CN=Genie,OU=Aladdin,OU=Disney,DC=insecure,DC=cyb
Jafar         Jafar          CN=Jafar,OU=Aladdin,OU=Disney,DC=insecure,DC=cyb
Iago          Iago           CN=Iago,OU=Aladdin,OU=Disney,DC=insecure,DC=cyb
Abu           Abu            CN=Abu,OU=Aladdin,OU=Disney,DC=insecure,DC=cyb
Carpet        Carpet         CN=Carpet,OU=Aladdin,OU=Disney,DC=insecure,DC=cyb
Sultan        Sultan         CN=Sultan,OU=Aladdin,OU=Disney,DC=insecure,DC=cyb
Rajah         Rajah          CN=Rajah,OU=Aladdin,OU=Disney,DC=insecure,DC=cyb
Simba         Simba          CN=Simba,OU=LionKing,OU=Disney,DC=insecure,DC=cyb
Nala          Nala           CN=Nala,OU=LionKing,OU=Disney,DC=insecure,DC=cyb
Timon         Timon          CN=Timon,OU=LionKing,OU=Disney,DC=insecure,DC=cyb
Pumbaa        Pumbaa         CN=Pumbaa,OU=LionKing,OU=Disney,DC=insecure,DC=cyb
Scar          Scar           CN=Scar,OU=LionKing,OU=Disney,DC=insecure,DC=cyb
Mufasa        Mufasa         CN=Mufasa,OU=LionKing,OU=Disney,DC=insecure,DC=cyb
Zazu          Zazu           CN=Zazu,OU=LionKing,OU=Disney,DC=insecure,DC=cyb
Rafiki        Rafiki         CN=Rafiki,OU=LionKing,OU=Disney,DC=insecure,DC=cyb
Sarabi        Sarabi         CN=Sarabi,OU=LionKing,OU=Disney,DC=insecure,DC=cyb
Sarafina      Sarafina       CN=Sarafina,OU=LionKing,OU=Disney,DC=insecure,DC=cyb
Shenzi        Shenzi         CN=Shenzi,OU=LionKing,OU=Disney,DC=insecure,DC=cyb
Banzai        Banzai         CN=Banzai,OU=LionKing,OU=Disney,DC=insecure,DC=cyb
Ed            Ed             CN=Ed,OU=LionKing,OU=Disney,DC=insecure,DC=cyb
Gopher        Gopher         CN=Gopher,OU=LionKing,OU=Disney,DC=insecure,DC=cyb
cyb-dc        cyb-dc         CN=cyb-dc,CN=Users,DC=insecure,DC=cyb
```

## Explore (maybe again)

The configuration of the webserver (the <http://www.insecure.cyb> website) and how it is connected to the database, what are the credentials, is this secure?

[This is already covered in the previous sections.](#credentials-on-website-to-connect-to-the-database)

The configuration of the webserver as a reverse proxy to <http://www.insecure.cyb/cmd>. How is this setup, explore the reverse proxy configuration and the systemd config file. What port is the java app running? Where is the jar located? Where is the systemd configuration file located? How can you bring this application down without bringing <http://www.insecure.cyb> down?

- Java application:
  - Port: **8000**
  - Location of the jar: `/opt/insecurewebapp/app.jar`
  - Location of the systemd configuration file: `/etc/systemd/system/insecurewebapp.service`
  - How to bring the application down without bringing the website down:
    - `sudo systemctl stop insecurewebapp.service`

## SSH Client Config

Create a SSH client configuration on your host in such a way that you can easily connect over SSH to all machines of the network. Use a jump / bastion host if necessary. While testing you can use the credentials of vagrant but refer to the theory for more suitable methods. Document properly how you implemented this, make sure you are able to explain how everything works. What files are transferred to what machines? Ask yourself is this is the most secure method and be very critical!

Note: if you don't want to fiddle with your (own host / ) Windows, you can always configure everything from one of the routers. That way you treat that machine as your "host". We do believe however that if you choose to run Windows a daily driver, it is worth getting this up and running.

### SSH Client Configuration

Make a file called `config` in the `.ssh` directory of your host machine. Add the following configuration (Make sure it has Full Control permissions):

```bash
Host companyrouter
    HostName 192.168.100.253
    User cyb
    IdentityFile C:\Users\JensV\.ssh\id_rsa

Host isprouter
    HostName 192.168.100.254
    User isprouter
    IdentityFile C:\Users\JensV\.ssh\id_rsa
    ProxyJump companyrouter

Host dc
    HostName 172.30.0.4
    User cyb-dc
    IdentityFile C:\Users\JensV\.ssh\id_rsa
    ProxyJump companyrouter

Host win10
    HostName 172.30.100.100
    User walt
    IdentityFile C:\Users\JensV\.ssh\id_rsa
    ProxyJump companyrouter

Host database
    HostName 172.30.0.5
    User cyb
    IdentityFile C:\Users\JensV\.ssh\id_rsa
    ProxyJump companyrouter

Host web
    HostName 172.30.20.10
    User cyb
    IdentityFile C:\Users\JensV\.ssh\id_rsa
    ProxyJump companyrouter
```

Now you can easily connect to the machines using the following commands:

```bash
ssh companyrouter
ssh isprouter
ssh dc
ssh win10
ssh database
ssh web
```
