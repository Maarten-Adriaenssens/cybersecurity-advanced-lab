# Setup IPsec

## Remoterouter

```bash
sudo ip xfrm policy flush
sudo ip xfrm state flush
cd sec/
sudo ./script1.sh
sudo ./script2.sh
sudo ip xfrm policy
sudo ip xfrm state
sudo tcpdump -i enp0s3 esp
```

## Companyrouter

```bash
sudo ip xfrm policy flush
sudo ip xfrm state flush
cd sec/
sudo ./script1.sh
sudo ./script2.sh
sudo ip xfrm policy
sudo ip xfrm state
sudo tcpdump -i eth0 esp
```

## Red Machine (2 terminals)

```bash
sudo ettercap -Tq -i enp0s3 -M arp:remote /192.168.100.103// /192.168.100.253//

sudo tshark -i enp0s3 esp or icmp

# Voor packet capture
sudo tshark -i enp0s3 -f "esp" -w /tmp/captureESP.pcap

sudo cp /tmp/captureESP.pcap /media/sf_SharedFolder/
```

## RemoteClient (Optional)

```bash
sudo tcpdump -i enp0s3 icmp
```

## Webserver

```bash
ping 172.123.0.10 -c4
```

## Decryptie

- Open WireShark `-> captureESP.pcap
- `Preferences -> ESP`
  - Check Attempt to detect/decode encrypted ESP payloads
  - In ESP SAs: Eerste SA
    - SPI: 0x007
    - Source IP: 192.168.100.103
    - Encryption: AES-CBC
    - Encryption Key: 0xfedcba9876543210fedcba9876543210
  - Tweede SA
    - SPI: 0x008
    - Source IP: 192.168.100.253
    - Encryption: AES-CBC
    - Encryption Key: 0x3e4c71a1b2c394a1d5e6f7c8a9b0c1d2e3f4a5b6c7d8e9f0