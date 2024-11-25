# Lab09 - Wazuh

```bash
cyb@wazuh:~$ sudo tar -axf wazuh-install-files.tar wazuh-install-files/wazuh-passwords.txt -O |
grep -P "\'admin\'" -A 1
  indexer_username: 'admin'
  indexer_password: 'g+H6BZBOLKTAB5zwD.3hQ8Wj5Gzy7ej3'
```

```bash
cyb@wazuh:~$ sudo tar -O -xvf wazuh-install-files.tar wazuh-install-files/wazuh-passwords.txt
wazuh-install-files/wazuh-passwords.txt
# Admin user for the web user interface and Wazuh indexer. Use this user to log in to Wazuh dashboard
  indexer_username: 'admin'
  indexer_password: 'g+H6BZBOLKTAB5zwD.3hQ8Wj5Gzy7ej3'

# Wazuh dashboard user for establishing the connection with Wazuh indexer
  indexer_username: 'kibanaserver'
  indexer_password: 'YMA*zxRcgCMbfps4Nzn6F8.n6KSmGuJG'

# Regular Dashboard user, only has read permissions to all indices and all permissions on the .kibana index
  indexer_username: 'kibanaro'
  indexer_password: 'gSVtA0H.*.LgZQG9WZRuBh2o3Cgx1OZ+'

# Filebeat user for CRUD operations on Wazuh indices
  indexer_username: 'logstash'
  indexer_password: 'paEV75Nn7Mi+*DjAulPsGq1Kbb0xqCB7'

# User with READ access to all indices
  indexer_username: 'readall'
  indexer_password: 'j2l?4+AfENOaAzmSIIc5qO8*DxZHRVyj'

# User with permissions to perform snapshot and restore operations
  indexer_username: 'snapshotrestore'
  indexer_password: 'JSheepJ+8NW.nwsDMw2*X49J3mOwHi76'

# Password for wazuh API user
  api_username: 'wazuh'
  api_password: 'we3sCD4VxKpgPGqpQkN2biR4U4W+8IzE'

# Password for wazuh-wui API user
  api_username: 'wazuh-wui'
  api_password: '8u38AaOzxs08SP5+jJZVB3FpxVaX9xI8'
```
<directories realtime="yes">/root</directories>
