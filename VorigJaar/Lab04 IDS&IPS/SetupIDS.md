# Setup

## Companyrouter

```bash
sudo systemctl start suricata
sudo systemctl enable suricata
```

### Wijzig regel

`sudo nano /etc/suricata/rules/local.rules`

`alert icmp any any -> any any (msg:"ICMP Ping detected"; sid:1000001; rev:1;)`

```bash
sudo systemctl restart suricata
```

### Zie pings verschijnen

Red:

```bash
ping 172.30.0.5 -c 4

telnet 172.30.0.5 3306
mysql -h 172.30.0.5 -u toor -p
```

Companyrouter:

```bash
sudo tail -f /var/log/suricata/fast.log

sudo tail -f /var/log/suricata/eve.json

```