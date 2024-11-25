# Setup BorgBackup

## Webserver (cyb@web)

1. Controleer de bestanden in de map ~/important-files:

    ```bash
    [cyb@web ~]$ ll ~/important-files/
    total 109992
    -rw-r--r--. 1 cyb cyb       300 Nov  4 12:37 100.txt
    -rw-r--r--. 1 cyb cyb       300 Nov  4 12:37 996.txt
    -rw-r--r--. 1 cyb cyb   1702187 Nov  4 12:37 Toreador_song_cleaned.ogg
    -rw-r--r--. 1 cyb cyb 110916740 Nov  4 12:37 bf1f3fb5-b119-4f9f-9930-8e20e892b898-720.mp4
    ```

2. Initialiseer een BorgBackup repository (als je dat nog niet hebt gedaan):

    ```bash
    [cyb@web ~]$ borg init --encryption=repokey ssh://cyb@172.30.0.5/~/backups
    ```

3. Exporteer de borg keyfile voor veilige opslag (als je dat nog niet hebt gedaan):

    ```bash
    [cyb@web ~]$ borg key export ssh://cyb@172.30.0.5/~/backups ~/borg_key.bak
    ```

4. Maak een eerste backup (als je dat nog niet hebt gedaan):

    ```bash
    [cyb@web ~]$ borg create --progress ssh://cyb@172.30.0.5/~/backups::first ~/important-files
    ```

5. Controleer de gemaakte backup:

    ```bash
    [cyb@web ~]$ borg info ssh://cyb@172.30.0.5/~/backups
    Enter passphrase for key ssh://cyb@172.30.0.5/~/backups:
    Repository ID: ff07eea40b0e6aadec34a7d1a31d6ea642efb2680241b0daacb7c118ba5805ed
    Location: ssh://cyb@172.30.0.5/~/backups
    Encrypted: Yes (repokey)
    Cache: /home/cyb/.cache/borg/ff07eea40b0e6aadec34a7d1a31d6ea642efb2680241b0daacb7c118ba5805ed
    Security dir: /home/cyb/.config/borg/security/ff07eea40b0e6aadec34a7d1a31d6ea642efb2680241b0daacb7c118ba5805ed
    ------------------------------------------------------------------------------
                        Original size      Compressed size    Deduplicated size
    All archives:              120.65 MB            117.50 MB            117.50 MB

                        Unique chunks         Total chunks
    Chunk index:                      59                   59
    ```

6. Voeg een testbestand toe en maak een tweede backup:

    ```bash
    [cyb@web ~]$ echo "Hello world" > ~/important-files/test.txt
    [cyb@web ~]$ borg create --progress ssh://cyb@172.30.0.5/~/backups::second ~/important-files
    ```

7. Controleer de nieuwe backup:

    ```bash
    [cyb@web ~]$ borg list ssh://cyb@172.30.0.5/~/backups
    Enter passphrase for key ssh://cyb@172.30.0.5/~/backups:
    first                                Sat, 2023-11-04 14:14:34 [1823882f3d5f38983cd0f34379cb3d9ac724305ee44fbeda047babf14f05578c]
    second                               Sat, 2023-11-04 14:56:02 [604151f437b6f36095b45478704cd8b876af357fbda8c9971d5a5d86abb61d39]
    ```

8. Controleer de integriteit van de backups:

    ```bash
    [cyb@web ~]$ borg check --verbose ssh://cyb@172.30.0.5/~/backups
    Remote: Starting repository check
    Remote: finished segment check at segment 9
    Remote: Starting repository index check
    Remote: Index object count match.
    Starting archive consistency check...
    Remote: Finished full repository check, no problems found.
    Enter passphrase for key ssh://cyb@172.30.0.5/~/backups:
    Analyzing archive first (1/2)
    Analyzing archive second (2/2)
    Archive consistency check complete, no problems found.
    ```

9. Verwijder de originele bestanden op de webserver:

    ```bash
    [cyb@web ~]$ rm --recursive --verbose ~/important-files/
    removed 'important-files/bf1f3fb5-b119-4f9f-9930-8e20e892b898-720.mp4'
    removed 'important-files/100.txt'
    removed 'important-files/996.txt'
    removed 'important-files/Toreador_song_cleaned.ogg'
    removed directory 'important-files/'
    ```

10. Herstel de originele bestanden vanaf de eerste backup:

    ```bash
    [cyb@web ~]$ borg extract --strip-components 2 ssh://cyb@172.30.0.5/~/backups::first ~/important-files
    [cyb@web ~]$ ll ~/important-files/
    total 109992
    -rw-r--r--. 1 cyb cyb       300 Nov  4 12:37 100.txt
    -rw-r--r--. 1 cyb cyb       300 Nov  4 12:37 996.txt
    -rw-r--r--. 1 cyb cyb   1702187 Nov  4 12:37 Toreador_song_cleaned.ogg
    -rw-r--r--. 1 cyb cyb 110916740 Nov  4 12:37 bf1f3fb5-b119-4f9f-9930-8e20e892b898-720.mp4
    ```

11. Automatiseer backups met een systemd timer:
    - Maak een backup script aan:

    ```bash
    cat <<EOF > ~/backup-script.sh
    #!/bin/bash
    REPO="ssh://cyb@172.30.0.5/~/backups"
    borg create --stats --progress \$REPO::"\$(date +'%Y-%m-%d_%H-%M-%S')" ~/important-files
    borg prune --list \$REPO --keep-daily=7 --keep-weekly=4 --keep-monthly=6
    EOF

    chmod +x ~/backup-script.sh
    ```

Maak en activeer de systemd service en timer:

/etc/systemd/system/backup.service:

```bash
[Unit]
Description=Backup Service

[Service]
Type=oneshot
ExecStart=/home/cyb/backup-script.sh
/etc/systemd/system/backup.timer:
```

```bash
[Unit]
Description=Run Borg Backup Every 5 Minutes

[Timer]
OnCalendar=*:0/5
Persistent=true

[Install]
WantedBy=timers.target
```

Activeer de timer:


```bash
sudo systemctl enable backup.timer
sudo systemctl start backup.timer
systemctl status backup.timer
```
