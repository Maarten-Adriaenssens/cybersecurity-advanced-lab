# Open Network Ports

**Companyrouter (4 Adapters)**:

```bash
[cyb@companyrouter ~]$ sudo ss -tuln
Netid    State     Recv-Q    Send-Q       Local Address:Port        Peer Address:Port    Process
udp      UNCONN    0         0                  0.0.0.0:67               0.0.0.0:*
udp      UNCONN    0         0                  0.0.0.0:111              0.0.0.0:*
udp      UNCONN    0         0                127.0.0.1:323              0.0.0.0:*
udp      UNCONN    0         0                     [::]:111                 [::]:*
udp      UNCONN    0         0                    [::1]:323                 [::]:*
tcp      LISTEN    0         128                0.0.0.0:22               0.0.0.0:*
tcp      LISTEN    0         4096               0.0.0.0:111              0.0.0.0:*
tcp      LISTEN    0         128                   [::]:22                  [::]:*
tcp      LISTEN    0         4096                  [::]:111                 [::]:*
[cyb@companyrouter ~]$
```

**ISPRouter (192.168.100.254)**:

```bash
isprouter:~# sudo netstat -tuln
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN
tcp        0      0 :::22                   :::*                    LISTEN
udp        0      0 0.0.0.0:67              0.0.0.0:*
isprouter:~#
```

**Database (172.30.0.5/24)**:

```bash
[cyb@database ~]$ sudo ss -tuln
Netid  State   Recv-Q  Send-Q   Local Address:Port    Peer Address:Port  Process
udp    UNCONN  0       0            127.0.0.1:323          0.0.0.0:*
udp    UNCONN  0       0              0.0.0.0:111          0.0.0.0:*
udp    UNCONN  0       0                [::1]:323             [::]:*
udp    UNCONN  0       0                 [::]:111             [::]:*
tcp    LISTEN  0       4096           0.0.0.0:111          0.0.0.0:*
tcp    LISTEN  0       128            0.0.0.0:22           0.0.0.0:*
tcp    LISTEN  0       4096           0.0.0.0:3306         0.0.0.0:*
tcp    LISTEN  0       70                   *:33060              *:*
tcp    LISTEN  0       4096              [::]:111             [::]:*
tcp    LISTEN  0       128               [::]:22              [::]:*
[cyb@database ~]$
```

**Webserver (172.30.20.10/24)**:

```bash
[cyb@web ~]$ sudo ss -tuln
Netid  State   Recv-Q  Send-Q   Local Address:Port    Peer Address:Port  Process
udp    UNCONN  0       0            127.0.0.1:323          0.0.0.0:*
udp    UNCONN  0       0              0.0.0.0:111          0.0.0.0:*
udp    UNCONN  0       0                [::1]:323             [::]:*
udp    UNCONN  0       0                 [::]:111             [::]:*
tcp    LISTEN  0       128            0.0.0.0:22           0.0.0.0:*
tcp    LISTEN  0       511            0.0.0.0:80           0.0.0.0:*
tcp    LISTEN  0       4096           0.0.0.0:111          0.0.0.0:*
tcp    LISTEN  0       128               [::]:22              [::]:*
tcp    LISTEN  0       4096                 *:8000               *:*
tcp    LISTEN  0       4096              [::]:111             [::]:*
[cyb@web ~]$
```

**DC (172.30.0.4/24)**:

```powershell
PS C:\Users\cyb-dc.insecure> netstat -an | findstr LISTENING
  TCP    0.0.0.0:22             0.0.0.0:0              LISTENING
  TCP    0.0.0.0:88             0.0.0.0:0              LISTENING
  TCP    0.0.0.0:135            0.0.0.0:0              LISTENING
  TCP    0.0.0.0:389            0.0.0.0:0              LISTENING
  TCP    0.0.0.0:445            0.0.0.0:0              LISTENING
  TCP    0.0.0.0:464            0.0.0.0:0              LISTENING
  TCP    0.0.0.0:593            0.0.0.0:0              LISTENING
  TCP    0.0.0.0:636            0.0.0.0:0              LISTENING
  TCP    0.0.0.0:3268           0.0.0.0:0              LISTENING
  TCP    0.0.0.0:3269           0.0.0.0:0              LISTENING
  TCP    0.0.0.0:3389           0.0.0.0:0              LISTENING
  TCP    0.0.0.0:5985           0.0.0.0:0              LISTENING
  TCP    0.0.0.0:9389           0.0.0.0:0              LISTENING
  TCP    0.0.0.0:47001          0.0.0.0:0              LISTENING
  TCP    0.0.0.0:49664          0.0.0.0:0              LISTENING
  TCP    0.0.0.0:49665          0.0.0.0:0              LISTENING
  TCP    0.0.0.0:49666          0.0.0.0:0              LISTENING
  TCP    0.0.0.0:49667          0.0.0.0:0              LISTENING
  TCP    0.0.0.0:49668          0.0.0.0:0              LISTENING
  TCP    0.0.0.0:54759          0.0.0.0:0              LISTENING
  TCP    0.0.0.0:54762          0.0.0.0:0              LISTENING
  TCP    0.0.0.0:54768          0.0.0.0:0              LISTENING
  TCP    0.0.0.0:54781          0.0.0.0:0              LISTENING
  TCP    0.0.0.0:61707          0.0.0.0:0              LISTENING
  TCP    127.0.0.1:53           0.0.0.0:0              LISTENING
  TCP    172.30.0.4:53          0.0.0.0:0              LISTENING
  TCP    172.30.0.4:139         0.0.0.0:0              LISTENING
  TCP    [::]:22                [::]:0                 LISTENING
  TCP    [::]:88                [::]:0                 LISTENING
  TCP    [::]:135               [::]:0                 LISTENING
  TCP    [::]:389               [::]:0                 LISTENING
  TCP    [::]:445               [::]:0                 LISTENING
  TCP    [::]:464               [::]:0                 LISTENING
  TCP    [::]:593               [::]:0                 LISTENING
  TCP    [::]:636               [::]:0                 LISTENING
  TCP    [::]:3268              [::]:0                 LISTENING
  TCP    [::]:3269              [::]:0                 LISTENING
  TCP    [::]:3389              [::]:0                 LISTENING
  TCP    [::]:5985              [::]:0                 LISTENING
  TCP    [::]:9389              [::]:0                 LISTENING
  TCP    [::]:47001             [::]:0                 LISTENING
  TCP    [::]:49664             [::]:0                 LISTENING
  TCP    [::]:49665             [::]:0                 LISTENING
  TCP    [::]:49666             [::]:0                 LISTENING
  TCP    [::]:49667             [::]:0                 LISTENING
  TCP    [::]:49668             [::]:0                 LISTENING
  TCP    [::]:54759             [::]:0                 LISTENING
  TCP    [::]:54762             [::]:0                 LISTENING
  TCP    [::]:54768             [::]:0                 LISTENING
  TCP    [::]:54781             [::]:0                 LISTENING
  TCP    [::]:61707             [::]:0                 LISTENING
  TCP    [::1]:53               [::]:0                 LISTENING
  TCP    [fe80::9445:a401:1320:f266%5]:53  [::]:0                 LISTENING
PS C:\Users\cyb-dc.insecure>
```
