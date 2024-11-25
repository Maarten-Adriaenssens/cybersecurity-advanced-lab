```console

red@machine:~$ nmap -sV -A 172.30.0.0/24
Starting Nmap 7.93 ( https://nmap.org ) at 2024-08-02 18:07 CEST
Nmap scan report for 172.30.0.5
Host is up (0.0015s latency).
Not shown: 997 closed tcp ports (conn-refused)
PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 8.7 (protocol 2.0)
| ssh-hostkey:
|   256 3781735afffe28e41d282616c2c88b6a (ECDSA)
|_  256 90d8bed196143b9bd29d52658ba97727 (ED25519)
111/tcp  open  rpcbind 2-4 (RPC #100000)
| rpcinfo:
|   program version    port/proto  service
|   100000  2,3,4        111/tcp   rpcbind
|   100000  2,3,4        111/udp   rpcbind
|   100000  3,4          111/tcp6  rpcbind
|_  100000  3,4          111/udp6  rpcbind
3306/tcp open  mysql   MySQL 8.0.32
|_ssl-date: TLS randomness does not represent time
| mysql-info:
|   Protocol: 10
|   Version: 8.0.32
|   Thread ID: 24
|   Capabilities flags: 65535
|   Some Capabilities: Support41Auth, LongPassword, Speaks41ProtocolOld, FoundRows, SupportsTransactions, ConnectWithDatabase, IgnoreSigpipes, SwitchToSSLAfterHandshake, ODBCClient, LongColumnFlag, SupportsLoadDataLocal, InteractiveClient, DontAllowDatabaseTableColumn, IgnoreSpaceBeforeParenthesis, Speaks41ProtocolNew, SupportsCompression, SupportsMultipleStatments, SupportsMultipleResults, SupportsAuthPlugins
|   Status: Autocommit
|   Salt: 2\x18?w:\x12\x1C:\\x18\x0F{.s<6P 'Z
|_  Auth Plugin Name: caching_sha2_password
| ssl-cert: Subject: commonName=MySQL_Server_8.0.32_Auto_Generated_Server_Certificate
| Not valid before: 2023-09-20T14:20:11
|_Not valid after:  2033-09-17T14:20:11

Nmap scan report for 172.30.0.254
Host is up (0.0027s latency).
Not shown: 998 closed tcp ports (conn-refused)
PORT    STATE SERVICE VERSION
22/tcp  open  ssh     OpenSSH 8.7 (protocol 2.0)
| ssh-hostkey:
|   256 007b51cb40f47668a2ff80014494c14e (ECDSA)
|_  256 e09c74dd769f27f86d564ae4d698076f (ED25519)
111/tcp open  rpcbind 2-4 (RPC #100000)
| rpcinfo:
|   program version    port/proto  service
|   100000  2,3,4        111/tcp   rpcbind
|   100000  2,3,4        111/udp   rpcbind
|   100000  3,4          111/tcp6  rpcbind
|_  100000  3,4          111/udp6  rpcbind

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 256 IP addresses (2 hosts up) scanned in 10.97 seconds
red@machine:~$ nmap -sV -A 172.30.20.0/24
Starting Nmap 7.93 ( https://nmap.org ) at 2024-08-02 18:08 CEST
WARNING: Service 172.30.20.10:8000 had already soft-matched rtsp, but now soft-matched sip; ignoring second value
Nmap scan report for insecure.cyb (172.30.20.10)
Host is up (0.00082s latency).
Not shown: 996 closed tcp ports (conn-refused)
PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 8.7 (protocol 2.0)
| ssh-hostkey:
|   256 8e2c66825b3c48557aa8477d70157fb7 (ECDSA)
|_  256 83ac88c332da51c7a19e9b418311f4d5 (ED25519)
80/tcp   open  http    Apache httpd 2.4.53 ((AlmaLinux))
|_http-title: Insecure Cyb
|_http-server-header: Apache/2.4.53 (AlmaLinux)
111/tcp  open  rpcbind 2-4 (RPC #100000)
| rpcinfo:
|   program version    port/proto  service
|   100000  2,3,4        111/tcp   rpcbind
|   100000  2,3,4        111/udp   rpcbind
|   100000  3,4          111/tcp6  rpcbind
|_  100000  3,4          111/udp6  rpcbind
8000/tcp open  rtsp
| fingerprint-strings:
|   FourOhFourRequest, HTTPOptions:
|     HTTP/1.0 404 Not Found
|     content-type: text/html; charset=utf-8
|     content-length: 53
|     <html><body><h1>Resource not found</h1></body></html>
|   GetRequest:
|     HTTP/1.0 200 OK
|     accept-ranges: bytes
|     content-length: 577
|     cache-control: public, immutable, max-age=86400
|     last-modified: Fri, 2 Aug 2024 16:08:33 GMT
|     date: Fri, 2 Aug 2024 16:08:33 GMT
|     content-type: text/html;charset=UTF-8
|     <!DOCTYPE html>
|     <html lang="en">
|     <head>
|     <meta charset="UTF-8">
|     <title>Command Injection</title>
|     <script src="assets/javascript/index.js"></script>
|     </head>
|     <body>
|     <h1>Command Injection</h1>
|     <form id="ping">
|     <h2>Ping a device</h2>
|     <label for="ip">Enter an IP address</label>
|     <input id="ip" type="text"/>
|     <input type="submit" value="PING">
|     </form>
|     <form id="exec">
|     <h2>Execute a command</h2>
|     <label for="cmd">Enter a command</label>
|     <input id="cmd" type="text"/>
|     <input type="submit" value="EXEC">
|     </form>
|     <pre></pre>
|     </body>
|     </html>
|   RTSPRequest:
|     RTSP/1.0 501 Not Implemented
|     content-length: 0
|   SIPOptions:
|     SIP/2.0 501 Not Implemented
|     content-length: 0
|   Socks5:
|     HTTP/1.0 400 Bad Request
|_    content-length: 0
|_http-title: Command Injection
|_rtsp-methods: ERROR: Script execution failed (use -d to debug)
1 service unrecognized despite returning data. If you know the service/version, please submit the following fingerprint at https://nmap.org/cgi-bin/submit.cgi?new-service :
SF-Port8000-TCP:V=7.93%I=7%D=8/2%Time=66AD0481%P=x86_64-pc-linux-gnu%r(Get
SF:Request,328,"HTTP/1\.0\x20200\x20OK\r\naccept-ranges:\x20bytes\r\nconte
SF:nt-length:\x20577\r\ncache-control:\x20public,\x20immutable,\x20max-age
SF:=86400\r\nlast-modified:\x20Fri,\x202\x20Aug\x202024\x2016:08:33\x20GMT
SF:\r\ndate:\x20Fri,\x202\x20Aug\x202024\x2016:08:33\x20GMT\r\ncontent-typ
SF:e:\x20text/html;charset=UTF-8\r\n\r\n<!DOCTYPE\x20html>\n<html\x20lang=
SF:\"en\">\n<head>\n\x20\x20\x20\x20<meta\x20charset=\"UTF-8\">\n\x20\x20\
SF:x20\x20<title>Command\x20Injection</title>\n\x20\x20\x20\x20<script\x20
SF:src=\"assets/javascript/index\.js\"></script>\n</head>\n<body>\n<h1>Com
SF:mand\x20Injection</h1>\n<form\x20id=\"ping\">\n\x20\x20\x20\x20<h2>Ping
SF:\x20a\x20device</h2>\n\x20\x20\x20\x20<label\x20for=\"ip\">Enter\x20an\
SF:x20IP\x20address</label>\n\x20\x20\x20\x20<input\x20id=\"ip\"\x20type=\
SF:"text\"/>\n\x20\x20\x20\x20<input\x20type=\"submit\"\x20value=\"PING\">
SF:\n</form>\n\n<form\x20id=\"exec\">\n\x20\x20\x20\x20<h2>Execute\x20a\x2
SF:0command</h2>\n\x20\x20\x20\x20<label\x20for=\"cmd\">Enter\x20a\x20comm
SF:and</label>\n\x20\x20\x20\x20<input\x20id=\"cmd\"\x20type=\"text\"/>\n\
SF:x20\x20\x20\x20<input\x20type=\"submit\"\x20value=\"EXEC\">\n</form>\n\
SF:n<pre></pre>\n</body>\n</html>\n")%r(FourOhFourRequest,8B,"HTTP/1\.0\x2
SF:0404\x20Not\x20Found\r\ncontent-type:\x20text/html;\x20charset=utf-8\r\
SF:ncontent-length:\x2053\r\n\r\n<html><body><h1>Resource\x20not\x20found<
SF:/h1></body></html>")%r(Socks5,2F,"HTTP/1\.0\x20400\x20Bad\x20Request\r\
SF:ncontent-length:\x200\r\n\r\n")%r(HTTPOptions,8B,"HTTP/1\.0\x20404\x20N
SF:ot\x20Found\r\ncontent-type:\x20text/html;\x20charset=utf-8\r\ncontent-
SF:length:\x2053\r\n\r\n<html><body><h1>Resource\x20not\x20found</h1></bod
SF:y></html>")%r(RTSPRequest,33,"RTSP/1\.0\x20501\x20Not\x20Implemented\r\
SF:ncontent-length:\x200\r\n\r\n")%r(SIPOptions,32,"SIP/2\.0\x20501\x20Not
SF:\x20Implemented\r\ncontent-length:\x200\r\n\r\n");

Nmap scan report for 172.30.20.254
Host is up (0.0017s latency).
Not shown: 998 closed tcp ports (conn-refused)
PORT    STATE SERVICE VERSION
22/tcp  open  ssh     OpenSSH 8.7 (protocol 2.0)
| ssh-hostkey:
|   256 007b51cb40f47668a2ff80014494c14e (ECDSA)
|_  256 e09c74dd769f27f86d564ae4d698076f (ED25519)
111/tcp open  rpcbind 2-4 (RPC #100000)
| rpcinfo:
|   program version    port/proto  service
|   100000  2,3,4        111/tcp   rpcbind
|   100000  2,3,4        111/udp   rpcbind
|   100000  3,4          111/tcp6  rpcbind
|_  100000  3,4          111/udp6  rpcbind

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 256 IP addresses (2 hosts up) scanned in 25.55 seconds
red@machine:~$ nmap -sV -A 172.30.100.0/24
Starting Nmap 7.93 ( https://nmap.org ) at 2024-08-02 18:08 CEST
Nmap scan report for 172.30.100.7
Host is up (0.00059s latency).
Not shown: 995 closed tcp ports (conn-refused)
PORT     STATE SERVICE       VERSION
22/tcp   open  ssh           OpenSSH for_Windows_8.0 (protocol 2.0)
| ssh-hostkey:
|   3072 965649e71db01c51a23c90b2f45d6b0a (RSA)
|   256 a2a604d35dbb075f58bdaa7b7bdb7b9b (ECDSA)
|_  256 e1215c82625ecffdb0da549974333205 (ED25519)
135/tcp  open  msrpc         Microsoft Windows RPC
139/tcp  open  netbios-ssn   Microsoft Windows netbios-ssn
445/tcp  open  microsoft-ds?
3389/tcp open  ms-wbt-server Microsoft Terminal Services
| rdp-ntlm-info:
|   Target_Name: insecure
|   NetBIOS_Domain_Name: insecure
|   NetBIOS_Computer_Name: WIN10
|   DNS_Domain_Name: insecure.cyb
|   DNS_Computer_Name: win10.insecure.cyb
|   DNS_Tree_Name: insecure.cyb
|   Product_Version: 10.0.19041
|_  System_Time: 2024-08-02T16:09:06+00:00
| ssl-cert: Subject: commonName=win10.insecure.cyb
| Not valid before: 2024-07-31T16:24:08
|_Not valid after:  2025-01-30T16:24:08
|_ssl-date: 2024-08-02T16:09:16+00:00; 0s from scanner time.
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-time:
|   date: 2024-08-02T16:09:10
|_  start_date: N/A
| smb2-security-mode:
|   311:
|_    Message signing enabled but not required

Nmap scan report for 172.30.100.254
Host is up (0.00075s latency).
Not shown: 998 closed tcp ports (conn-refused)
PORT    STATE SERVICE VERSION
22/tcp  open  ssh     OpenSSH 8.7 (protocol 2.0)
| ssh-hostkey:
|_  256 e09c74dd769f27f86d564ae4d698076f (ED25519)
111/tcp open  rpcbind 2-4 (RPC #100000)
| rpcinfo:
|   program version    port/proto  service
|   100000  2,3,4        111/tcp   rpcbind
|   100000  2,3,4        111/udp   rpcbind
|   100000  3,4          111/tcp6  rpcbind
|_  100000  3,4          111/udp6  rpcbind

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 256 IP addresses (2 hosts up) scanned in 21.88 seconds
red@machine:~$
```

```console
red@machine:~$ sudo nmap -sV -A 172.30.100.0/24
Starting Nmap 7.93 ( https://nmap.org ) at 2024-08-02 18:09 CEST
Nmap scan report for 172.30.100.7
Host is up (0.0013s latency).
Not shown: 995 closed tcp ports (reset)
PORT     STATE SERVICE       VERSION
22/tcp   open  ssh           OpenSSH for_Windows_8.0 (protocol 2.0)
| ssh-hostkey:
|   3072 965649e71db01c51a23c90b2f45d6b0a (RSA)
|   256 a2a604d35dbb075f58bdaa7b7bdb7b9b (ECDSA)
|_  256 e1215c82625ecffdb0da549974333205 (ED25519)
135/tcp  open  msrpc         Microsoft Windows RPC
139/tcp  open  netbios-ssn   Microsoft Windows netbios-ssn
445/tcp  open  microsoft-ds?
3389/tcp open  ms-wbt-server Microsoft Terminal Services
| rdp-ntlm-info:
|   Target_Name: insecure
|   NetBIOS_Domain_Name: insecure
|   NetBIOS_Computer_Name: WIN10
|   DNS_Domain_Name: insecure.cyb
|   DNS_Computer_Name: win10.insecure.cyb
|   DNS_Tree_Name: insecure.cyb
|   Product_Version: 10.0.19041
|_  System_Time: 2024-08-02T16:09:56+00:00
| ssl-cert: Subject: commonName=win10.insecure.cyb
| Not valid before: 2024-07-31T16:24:08
|_Not valid after:  2025-01-30T16:24:08
|_ssl-date: 2024-08-02T16:10:07+00:00; 0s from scanner time.
Device type: general purpose
Running: Microsoft Windows 10
OS CPE: cpe:/o:microsoft:windows_10
OS details: Microsoft Windows 10 1709 - 1803, Microsoft Windows 10 1709 - 1909
Network Distance: 2 hops
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-security-mode:
|   311:
|_    Message signing enabled but not required
| smb2-time:
|   date: 2024-08-02T16:10:01
|_  start_date: N/A

TRACEROUTE (using port 5900/tcp)
HOP RTT     ADDRESS
1   0.41 ms 192.168.100.253
2   0.90 ms 172.30.100.7

Nmap scan report for 172.30.100.254
Host is up (0.00068s latency).
Not shown: 998 closed tcp ports (reset)
PORT    STATE SERVICE VERSION
22/tcp  open  ssh     OpenSSH 8.7 (protocol 2.0)
| ssh-hostkey:
|   256 007b51cb40f47668a2ff80014494c14e (ECDSA)
|_  256 e09c74dd769f27f86d564ae4d698076f (ED25519)
111/tcp open  rpcbind 2-4 (RPC #100000)
| rpcinfo:
|   program version    port/proto  service
|   100000  2,3,4        111/tcp   rpcbind
|   100000  2,3,4        111/udp   rpcbind
|   100000  3,4          111/tcp6  rpcbind
|_  100000  3,4          111/udp6  rpcbind
Device type: general purpose
Running: Linux 4.X|5.X
OS CPE: cpe:/o:linux:linux_kernel:4 cpe:/o:linux:linux_kernel:5
OS details: Linux 4.15 - 5.6
Network Distance: 1 hop

TRACEROUTE (using port 5900/tcp)
HOP RTT     ADDRESS
1   0.47 ms 172.30.100.254

OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 256 IP addresses (2 hosts up) scanned in 24.16 seconds
red@machine:~$






red@machine:~$ sudo nmap -sV -A 172.30.20.0/24
Starting Nmap 7.93 ( https://nmap.org ) at 2024-08-02 18:12 CEST
WARNING: Service 172.30.20.10:8000 had already soft-matched rtsp, but now soft-matched sip; ignoring second value
Nmap scan report for insecure.cyb (172.30.20.10)
Host is up (0.0016s latency).
Not shown: 996 closed tcp ports (reset)
PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 8.7 (protocol 2.0)
| ssh-hostkey:
|   256 8e2c66825b3c48557aa8477d70157fb7 (ECDSA)
|_  256 83ac88c332da51c7a19e9b418311f4d5 (ED25519)
80/tcp   open  http    Apache httpd 2.4.53 ((AlmaLinux))
|_http-title: Insecure Cyb
|_http-server-header: Apache/2.4.53 (AlmaLinux)
111/tcp  open  rpcbind 2-4 (RPC #100000)
| rpcinfo:
|   program version    port/proto  service
|   100000  2,3,4        111/tcp   rpcbind
|   100000  2,3,4        111/udp   rpcbind
|   100000  3,4          111/tcp6  rpcbind
|_  100000  3,4          111/udp6  rpcbind
8000/tcp open  rtsp
|_rtsp-methods: ERROR: Script execution failed (use -d to debug)
| fingerprint-strings:
|   FourOhFourRequest, HTTPOptions:
|     HTTP/1.0 404 Not Found
|     content-type: text/html; charset=utf-8
|     content-length: 53
|     <html><body><h1>Resource not found</h1></body></html>
|   GetRequest:
|     HTTP/1.0 200 OK
|     accept-ranges: bytes
|     content-length: 577
|     cache-control: public, immutable, max-age=86400
|     last-modified: Fri, 2 Aug 2024 16:08:33 GMT
|     date: Fri, 2 Aug 2024 16:12:57 GMT
|     content-type: text/html;charset=UTF-8
|     <!DOCTYPE html>
|     <html lang="en">
|     <head>
|     <meta charset="UTF-8">
|     <title>Command Injection</title>
|     <script src="assets/javascript/index.js"></script>
|     </head>
|     <body>
|     <h1>Command Injection</h1>
|     <form id="ping">
|     <h2>Ping a device</h2>
|     <label for="ip">Enter an IP address</label>
|     <input id="ip" type="text"/>
|     <input type="submit" value="PING">
|     </form>
|     <form id="exec">
|     <h2>Execute a command</h2>
|     <label for="cmd">Enter a command</label>
|     <input id="cmd" type="text"/>
|     <input type="submit" value="EXEC">
|     </form>
|     <pre></pre>
|     </body>
|     </html>
|   RTSPRequest:
|     RTSP/1.0 501 Not Implemented
|     content-length: 0
|   SIPOptions:
|     SIP/2.0 501 Not Implemented
|     content-length: 0
|   Socks5:
|     HTTP/1.0 400 Bad Request
|_    content-length: 0
|_http-title: Command Injection
1 service unrecognized despite returning data. If you know the service/version, please submit the following fingerprint at https://nmap.org/cgi-bin/submit.cgi?new-service :
SF-Port8000-TCP:V=7.93%I=7%D=8/2%Time=66AD0589%P=x86_64-pc-linux-gnu%r(Get
SF:Request,328,"HTTP/1\.0\x20200\x20OK\r\naccept-ranges:\x20bytes\r\nconte
SF:nt-length:\x20577\r\ncache-control:\x20public,\x20immutable,\x20max-age
SF:=86400\r\nlast-modified:\x20Fri,\x202\x20Aug\x202024\x2016:08:33\x20GMT
SF:\r\ndate:\x20Fri,\x202\x20Aug\x202024\x2016:12:57\x20GMT\r\ncontent-typ
SF:e:\x20text/html;charset=UTF-8\r\n\r\n<!DOCTYPE\x20html>\n<html\x20lang=
SF:\"en\">\n<head>\n\x20\x20\x20\x20<meta\x20charset=\"UTF-8\">\n\x20\x20\
SF:x20\x20<title>Command\x20Injection</title>\n\x20\x20\x20\x20<script\x20
SF:src=\"assets/javascript/index\.js\"></script>\n</head>\n<body>\n<h1>Com
SF:mand\x20Injection</h1>\n<form\x20id=\"ping\">\n\x20\x20\x20\x20<h2>Ping
SF:\x20a\x20device</h2>\n\x20\x20\x20\x20<label\x20for=\"ip\">Enter\x20an\
SF:x20IP\x20address</label>\n\x20\x20\x20\x20<input\x20id=\"ip\"\x20type=\
SF:"text\"/>\n\x20\x20\x20\x20<input\x20type=\"submit\"\x20value=\"PING\">
SF:\n</form>\n\n<form\x20id=\"exec\">\n\x20\x20\x20\x20<h2>Execute\x20a\x2
SF:0command</h2>\n\x20\x20\x20\x20<label\x20for=\"cmd\">Enter\x20a\x20comm
SF:and</label>\n\x20\x20\x20\x20<input\x20id=\"cmd\"\x20type=\"text\"/>\n\
SF:x20\x20\x20\x20<input\x20type=\"submit\"\x20value=\"EXEC\">\n</form>\n\
SF:n<pre></pre>\n</body>\n</html>\n")%r(FourOhFourRequest,8B,"HTTP/1\.0\x2
SF:0404\x20Not\x20Found\r\ncontent-type:\x20text/html;\x20charset=utf-8\r\
SF:ncontent-length:\x2053\r\n\r\n<html><body><h1>Resource\x20not\x20found<
SF:/h1></body></html>")%r(Socks5,2F,"HTTP/1\.0\x20400\x20Bad\x20Request\r\
SF:ncontent-length:\x200\r\n\r\n")%r(HTTPOptions,8B,"HTTP/1\.0\x20404\x20N
SF:ot\x20Found\r\ncontent-type:\x20text/html;\x20charset=utf-8\r\ncontent-
SF:length:\x2053\r\n\r\n<html><body><h1>Resource\x20not\x20found</h1></bod
SF:y></html>")%r(RTSPRequest,33,"RTSP/1\.0\x20501\x20Not\x20Implemented\r\
SF:ncontent-length:\x200\r\n\r\n")%r(SIPOptions,32,"SIP/2\.0\x20501\x20Not
SF:\x20Implemented\r\ncontent-length:\x200\r\n\r\n");
No exact OS matches for host (If you know what OS is running on it, see https://nmap.org/submit/ ).
TCP/IP fingerprint:
OS:SCAN(V=7.93%E=4%D=8/2%OT=22%CT=1%CU=37592%PV=Y%DS=2%DC=T%G=Y%TM=66AD059F
OS:%P=x86_64-pc-linux-gnu)SEQ(SP=106%GCD=1%ISR=109%TI=Z%CI=Z%II=I%TS=A)SEQ(
OS:SP=106%GCD=1%ISR=109%TI=Z%CI=Z%TS=A)OPS(O1=M5B4ST11NW6%O2=M5B4ST11NW6%O3
OS:=M5B4NNT11NW6%O4=M5B4ST11NW6%O5=M5B4ST11NW6%O6=M5B4ST11)WIN(W1=FE88%W2=F
OS:E88%W3=FE88%W4=FE88%W5=FE88%W6=FE88)ECN(R=Y%DF=Y%T=40%W=FAF0%O=M5B4NNSNW
OS:6%CC=Y%Q=)T1(R=Y%DF=Y%T=40%S=O%A=S+%F=AS%RD=0%Q=)T2(R=N)T3(R=N)T4(R=Y%DF
OS:=Y%T=40%W=0%S=A%A=Z%F=R%O=%RD=0%Q=)T5(R=Y%DF=Y%T=40%W=0%S=Z%A=S+%F=AR%O=
OS:%RD=0%Q=)T6(R=Y%DF=Y%T=40%W=0%S=A%A=Z%F=R%O=%RD=0%Q=)T7(R=Y%DF=Y%T=40%W=
OS:0%S=Z%A=S+%F=AR%O=%RD=0%Q=)U1(R=Y%DF=N%T=40%IPL=164%UN=0%RIPL=G%RID=G%RI
OS:PCK=G%RUCK=G%RUD=G)IE(R=Y%DFI=N%T=40%CD=S)

Network Distance: 2 hops

TRACEROUTE (using port 8080/tcp)
HOP RTT     ADDRESS
1   0.32 ms 192.168.100.253
2   0.52 ms insecure.cyb (172.30.20.10)

Nmap scan report for 172.30.20.254
Host is up (0.00047s latency).
Not shown: 998 closed tcp ports (reset)
PORT    STATE SERVICE VERSION
22/tcp  open  ssh     OpenSSH 8.7 (protocol 2.0)
| ssh-hostkey:
|   256 007b51cb40f47668a2ff80014494c14e (ECDSA)
|_  256 e09c74dd769f27f86d564ae4d698076f (ED25519)
111/tcp open  rpcbind 2-4 (RPC #100000)
| rpcinfo:
|   program version    port/proto  service
|   100000  2,3,4        111/tcp   rpcbind
|   100000  2,3,4        111/udp   rpcbind
|   100000  3,4          111/tcp6  rpcbind
|_  100000  3,4          111/udp6  rpcbind
Device type: general purpose
Running: Linux 4.X|5.X
OS CPE: cpe:/o:linux:linux_kernel:4 cpe:/o:linux:linux_kernel:5
OS details: Linux 4.15 - 5.6
Network Distance: 1 hop

TRACEROUTE (using port 8080/tcp)
HOP RTT     ADDRESS
1   0.32 ms 172.30.20.254

OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 256 IP addresses (2 hosts up) scanned in 37.80 seconds











red@machine:~$ sudo nmap -sV -A 172.30.0.0/24
Starting Nmap 7.93 ( https://nmap.org ) at 2024-08-02 18:13 CEST
Nmap scan report for 172.30.0.4
Host is up (0.0015s latency).
Not shown: 987 filtered tcp ports (no-response)
PORT     STATE SERVICE       VERSION
22/tcp   open  ssh           OpenSSH for_Windows_8.0 (protocol 2.0)
| ssh-hostkey:
|   3072 f6697c71d51e8258924d4eeacba3ffb1 (RSA)
|   256 62fff4b81282b6d9c08d3641696cd44a (ECDSA)
|_  256 8294ffc7de7605e11be894d3508ea346 (ED25519)
53/tcp   open  domain        Simple DNS Plus
88/tcp   open  kerberos-sec  Microsoft Windows Kerberos (server time: 2024-08-02 16:13:44Z)
135/tcp  open  msrpc         Microsoft Windows RPC
139/tcp  open  netbios-ssn   Microsoft Windows netbios-ssn
389/tcp  open  ldap          Microsoft Windows Active Directory LDAP (Domain: insecure.cyb0., Site: Default-First-Site-Name)
445/tcp  open  microsoft-ds?
464/tcp  open  kpasswd5?
593/tcp  open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
636/tcp  open  tcpwrapped
3268/tcp open  ldap          Microsoft Windows Active Directory LDAP (Domain: insecure.cyb0., Site: Default-First-Site-Name)
3269/tcp open  tcpwrapped
3389/tcp open  ms-wbt-server Microsoft Terminal Services
|_ssl-date: 2024-08-02T16:14:28+00:00; 0s from scanner time.
| rdp-ntlm-info:
|   Target_Name: insecure
|   NetBIOS_Domain_Name: insecure
|   NetBIOS_Computer_Name: DC
|   DNS_Domain_Name: insecure.cyb
|   DNS_Computer_Name: dc.insecure.cyb
|   DNS_Tree_Name: insecure.cyb
|   Product_Version: 10.0.20348
|_  System_Time: 2024-08-02T16:13:49+00:00
| ssl-cert: Subject: commonName=dc.insecure.cyb
| Not valid before: 2024-07-30T08:15:15
|_Not valid after:  2025-01-29T08:15:15
Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port
Device type: general purpose
Running (JUST GUESSING): Microsoft Windows 2016|10|2012|Vista (93%)
OS CPE: cpe:/o:microsoft:windows_server_2016 cpe:/o:microsoft:windows_10 cpe:/o:microsoft:windows_server_2012:r2 cpe:/o:microsoft:windows_vista::sp1:home_premium
Aggressive OS guesses: Microsoft Windows Server 2016 (93%), Microsoft Windows 10 (89%), Microsoft Windows Server 2012 or Windows Server 2012 R2 (87%), Microsoft Windows Vista Home Premium SP1 (85%), Microsoft Windows Server 2012 R2 (85%)
No exact OS matches for host (test conditions non-ideal).
Network Distance: 2 hops
Service Info: Host: DC; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-time:
|   date: 2024-08-02T16:13:49
|_  start_date: N/A
| smb2-security-mode:
|   311:
|_    Message signing enabled and required

TRACEROUTE (using port 445/tcp)
HOP RTT     ADDRESS
-   Hop 1 is the same as for 172.30.0.5
2   1.02 ms 172.30.0.4

Nmap scan report for 172.30.0.5
Host is up (0.0012s latency).
Not shown: 997 closed tcp ports (reset)
PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 8.7 (protocol 2.0)
| ssh-hostkey:
|   256 3781735afffe28e41d282616c2c88b6a (ECDSA)
|_  256 90d8bed196143b9bd29d52658ba97727 (ED25519)
111/tcp  open  rpcbind 2-4 (RPC #100000)
| rpcinfo:
|   program version    port/proto  service
|   100000  2,3,4        111/tcp   rpcbind
|   100000  2,3,4        111/udp   rpcbind
|   100000  3,4          111/tcp6  rpcbind
|_  100000  3,4          111/udp6  rpcbind
3306/tcp open  mysql   MySQL 8.0.32
| mysql-info:
|   Protocol: 10
|   Version: 8.0.32
|   Thread ID: 84
|   Capabilities flags: 65535
|   Some Capabilities: SupportsTransactions, FoundRows, Speaks41ProtocolOld, Support41Auth, Speaks41ProtocolNew, SwitchToSSLAfterHandshake, ODBCClient, InteractiveClient, SupportsLoadDataLocal, IgnoreSigpipes, IgnoreSpaceBeforeParenthesis, DontAllowDatabaseTableColumn, LongColumnFlag, ConnectWithDatabase, LongPassword, SupportsCompression, SupportsAuthPlugins, SupportsMultipleStatments, SupportsMultipleResults
|   Status: Autocommit
|   Salt: \x0D\x19&|b\x05\x16\\x1BP~\x054Q\x04[HRT,
|_  Auth Plugin Name: caching_sha2_password
| ssl-cert: Subject: commonName=MySQL_Server_8.0.32_Auto_Generated_Server_Certificate
| Not valid before: 2023-09-20T14:20:11
|_Not valid after:  2033-09-17T14:20:11
|_ssl-date: TLS randomness does not represent time
Device type: general purpose
Running: Linux 4.X|5.X
OS CPE: cpe:/o:linux:linux_kernel:4 cpe:/o:linux:linux_kernel:5
OS details: Linux 4.15 - 5.6
Network Distance: 2 hops

TRACEROUTE (using port 587/tcp)
HOP RTT     ADDRESS
1   0.46 ms 192.168.100.253
2   0.84 ms 172.30.0.5

Nmap scan report for 172.30.0.254
Host is up (0.00061s latency).
Not shown: 998 closed tcp ports (reset)
PORT    STATE SERVICE VERSION
22/tcp  open  ssh     OpenSSH 8.7 (protocol 2.0)
| ssh-hostkey:
|   256 007b51cb40f47668a2ff80014494c14e (ECDSA)
|_  256 e09c74dd769f27f86d564ae4d698076f (ED25519)
111/tcp open  rpcbind 2-4 (RPC #100000)
| rpcinfo:
|   program version    port/proto  service
|   100000  2,3,4        111/tcp   rpcbind
|   100000  2,3,4        111/udp   rpcbind
|   100000  3,4          111/tcp6  rpcbind
|_  100000  3,4          111/udp6  rpcbind
Device type: general purpose
Running: Linux 4.X|5.X
OS CPE: cpe:/o:linux:linux_kernel:4 cpe:/o:linux:linux_kernel:5
OS details: Linux 4.15 - 5.6
Network Distance: 1 hop

TRACEROUTE (using port 587/tcp)
HOP RTT     ADDRESS
1   0.47 ms 172.30.0.254

OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 256 IP addresses (3 hosts up) scanned in 61.23 seconds


```