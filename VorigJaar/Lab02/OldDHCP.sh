# [cyb@companyrouter ~]$ sudo cat /etc/dhcp/dhcpd.conf
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


subnet 172.30.0.0 netmask 255.255.0.0 {
  range 172.30.10.100 172.30.10.200;
  option routers 172.30.255.254;
}