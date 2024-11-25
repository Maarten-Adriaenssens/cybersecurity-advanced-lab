# Lab07 - BorgBackup

## Introduction

Although protection is very important, you can never rely on the fact that your network and machines are 100% protected. Sometimes bad actors find a way in through a security hole you didn't know existed, or sometimes software/hardware just fails. It is **important** that you **always keep backups** of important data. In the theory notes you'll find a lot of best practices and ways to keep backups so be sure to keep these in mind!

In this lab, we'll explore a way to backup data to another machine. Although some people just set up a periodic `rclone` job, this has some drawbacks. We are looking for a backup solution that has the following advantages

- Backups can be automated. This way, backups won't be forgotten.
- Backups are immutable. Once backed up, the data cannot be changed. Cloud syncing (OneDrive, Google Drive, DropBox, MEGA, ...) or RAID are not backups! Why? Can you think of a malware attack that demonstrates this?
- Backups are encrypted.
- Backups can be done to a remote machine (preferably through existing technologies such as SSH and SFTP).
- Backups are incremental. Only delta's are stored between backups following each other. E.g. If only 1 byte has changed of the 100 GB of data, it has no use to keep 2 times a full backup of 100GB. Just store the full data with the initial backup and then store what has changed between backups (the so called deltas). This greatly saves storage space and allows you to have a lot of backups that represent different snapshots in time of your data.
- It is possible to have a retention policy. E.g. although that you take a backup every week, you can specify that only the last 20 backups must be kept and 1 for every month for the last 2 years and 1 for every year for older backups. All the rest will be automatically cleaned up every time you make a backup, what greatly reduces storage space.
- Deduplication is supported. The backup data is split in blocks and a hash for each block is created and stored. If multiple blocks have the same hash, they are identical. There is no need to store these blocks multiple times, just store it once, and the similar blocks will just link to the actual block. - - This can also greatly reduce storage space.
- It is possible to verify if backups are corrupted.
- It easy to retrieve the data stored in backups.
- The software is trusted and tested!

## BorgBackup

We have chosen BorgBackup for this lab. `borg` is relatively easy to use, and has all the requested features and many more!

In this lab, we have the following files we would like to back up regularly:

A video file you can download from <https://video.blender.org/download/videos/bf1f3fb5-b119-4f9f-9930-8e20e892b898-720.mp4>
2 text files you can download from ...
<https://www.gutenberg.org/ebooks/100.txt.utf-8>
<https://www.gutenberg.org/ebooks/996.txt.utf-8>
An audio fragment you can dowload from <https://upload.wikimedia.org/wikipedia/commons/4/40/Toreador_song_cleaned.ogg>

## Execute the following steps

1. Create a folder on the web VM and store the files (e.g. ~/important-files). Use curl with the --location and --remote-name-all options. What do these options do? Why do you need them? Do you really need them? What happens without them?

    ```bash
    [vagrant@web ~]$ mkdir important-files
    [vagrant@web ~]$ cd !$
    [vagrant@web important-files]$ curl --remote-name-all https://video.blender.org/download/videos/bf1f3fb5-b119-4f9f-9930-8e20e892b898-720.mp4 https://www.gutenberg.org/ebooks/100.txt.utf-8 https://www.gutenberg.org/ebooks/996.txt.utf-8 https://upload.wikimedia.org/wikipedia/commons/4/40/Toreador_song_cleaned.ogg
    [vagrant@web important-files]$ mv 100.txt.utf-8 100.txt # Optional
    [vagrant@web important-files]$ mv 996.txt.utf-8 996.txt # Optional
    [vagrant@web important-files]$ ll
    total 109992
    -rw-r--r--. 1 vagrant vagrant       300 Nov  4 12:37 100.txt
    -rw-r--r--. 1 vagrant vagrant       300 Nov  4 12:37 996.txt
    -rw-r--r--. 1 vagrant vagrant   1702187 Nov  4 12:37 Toreador_song_cleaned.ogg
    -rw-r--r--. 1 vagrant vagrant 110916740 Nov  4 12:37 bf1f3fb5-b119-4f9f-9930-8e20e892b898-720.mp4
    ```

2. Create a folder on the `db` VM to store the backups (e.g. ~/backups).

    ```bash
    [vagrant@db ~]$ mkdir -p ~/backups
    [vagrant@db ~]$ cd !$
    [vagrant@db backups]$ ll
    total 0
    ```

3. Install `borg` on both the machine were the files are used, and the machine were the backups will be stored. As `borg` is only available on linux machines [^1] and we don't want to introduce another VM to burden your laptop further, we will store the active versions of the files on `web` and the backup `db` VM. It is important that **both** machines have borg installed.

    There are always multiple ways to install software on a machine, such as `pip`, `npm`, a downloadable executable, `flatpak`, ... . The best way is always through the distro's package manager, which you always should try first:

    - All files are signed and thus the chance is small the packages have been tampered with.

    - The packages are often adjusted for use with the specific distro, or additional documentation / default configuration files have been added.

    - The package is update when upgrading all packages using the package manager.

    - If we search for borg on AlmaLinux, we'll see that it is not available through the package manager dnf

        ```bash
        [vagrant@web ~]$ sudo dnf search borgbackup
        Last metadata expiration check: 0:13:42 ago on Sat Nov  4 12:54:17 2023.
        No matches found.
        ```

    - Fortunately, AlmaLinux allows support for an additional heap of important and handy packages. To access this, we need to do enable the EPEL repository. You'll find information about how to do this in the official AlmaLinux documentation online. Try to resist the urge to look at some random blogpost or tutorial: often these are outdated or endorse a "hackier" approach, while you'll see in the official AlmaLinux documentation that you don't need to do much or anything difficult to enable the EPEL repository to have access to the borg tool. One important detail: you'll need to expand the RAM memory of the VM's which use the EPEL repository to at least 1 GB, otherwise you'll just get Killed as output to the dnf commands.

    - If all goes well, you'll be able to do the following

        ```bash
        [vagrant@web ~]$ sudo dnf search borgbackup
        Last metadata expiration check: 0:15:55 ago on Sat Nov  4 12:54:21 2023.
        ========================================= Name Exactly Matched: borgbackup =========================================
        borgbackup.x86_64 : A deduplicating backup program with compression and authenticated encryption
        =========================================== Summary Matched: borgbackup ============================================
        borgmatic.noarch : Simple Python wrapper script for borgbackup
        ```

        If this succeeds, you'll be able to install borg using dnf

        - Web RAM: 512MB -> 2048MB
        - DB RAM: 1024MB -> 2048MB

        ```bash
        sudo dnf install epel-release -y
        sudo dnf install borgbackup -y
        ```

        - The EPEL repository contains additional packages that are not available in the standard AlmaLinux repositories.

4. From the webserver, initialize a backup repository on db. This repository will contain all the created backups. Make sure you use the repokey` encryption mode!

    Because borg uses SSH, you'll notice that SSH asks you for the password for vagrant@<db-ip> whenever you access the repository using borg. Use SSH key authentication so you don't have to type the password anymore. How do you do this? Which command makes it really easy to configure this? Note: you still will have to type in your borg key. The SSH key is for the encrypted connection, the borg key is to make sure the backups are encrypted on the storage of the remote server (e.g. an admin of the remote server can't see the contents of your backups). There are also various ways to automatically provide the borg key.

    ```bash
    [cyb@web ~]$ borg init --encryption=repokey ssh://cyb@172.30.0.5/~/backups
    The authenticity of host '172.30.0.5 (172.30.0.5)' can't be established.
    ED25519 key fingerprint is SHA256:0DWHYG8LGaH3HKqFFxbHs6Ipnr2aYrjIoyT1t1a3Qfc.
    This key is not known by any other names
    Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
    Remote: Warning: Permanently added '172.30.0.5' (ED25519) to the list of known hosts.
    cyb@172.30.0.5's password:
    Enter new passphrase:
    Enter same passphrase again:
    Do you want your passphrase to be displayed for verification? [yN]: N

    By default repositories initialized with this version will produce security
    errors if written to with an older version (up to and including Borg 1.0.8).

    If you want to use these older versions, you can disable the check by running:
    borg upgrade --disable-tam 'ssh://cyb@172.30.0.5/~/backups'

    See https://borgbackup.readthedocs.io/en/stable/changes.html#pre-1-0-9-manifest-spoofing-vulnerability for details about the security implications.

    IMPORTANT: you will need both KEY AND PASSPHRASE to access this repo!
    If you used a repokey mode, the key is stored in the repo, but you should back it up separately.
    Use "borg key export" to export the key, optionally in printable format.
    Write down the passphrase. Store both at safe place(s).
    ```

5. Export the borg keyfile in a readable format so you can store it on a safe location. The keyfile was generated automatically when you initialized the backup repository and stored on the web server (because that's from where you initialized the backup repository). You need both the borg key and the borg keyfile to access the backups. If you lose the borg keyfile (e.g. the SSD/HDD on web has been damaged or wiped), you won't be able to access the backups anymore. You best keep a backup of the keyfile outside your backup repository. Make sure you don't lock yourself out by "leaving your keys inside your car".

    ```bash
    [cyb@web ~]$ borg key export ssh://cyb@172.30.0.5/~/backups ~/borg_key.bak
    ```

6. Create a backup, make sure it is called `first`.

    ```bash
    [cyb@web ~]$ borg create --progress ssh://cyb@172.30.0.5/~/backups::first ~/important-files
    ```

7. List all backups. You should see a similar output as the following:

    ```bash
    [vagrant@web ~]$ borg info vagrant@172.30.20.15:~/backups
    Enter passphrase for key ssh://vagrant@172.30.20.15/~/backups:
    Repository ID: ff07eea40b0e6aadec34a7d1a31d6ea642efb2680241b0daacb7c118ba5805ed
    Location: ssh://vagrant@172.30.20.15/~/backups
    Encrypted: Yes (repokey)
    Cache: /home/vagrant/.cache/borg/ff07eea40b0e6aadec34a7d1a31d6ea642efb2680241b0daacb7c118ba5805ed
    Security dir: /home/vagrant/.config/borg/security/ff07eea40b0e6aadec34a7d1a31d6ea642efb2680241b0daacb7c118ba5805ed
    ------------------------------------------------------------------------------
                        Original size      Compressed size    Deduplicated size
    All archives:              120.65 MB            117.50 MB            117.50 MB

                        Unique chunks         Total chunks
    Chunk index:                      59                   59
    ```

    - My output

        ```bash
        [cyb@web ~]$ borg info cyb@172.30.0.5:~/backups
        Enter passphrase for key ssh://cyb@172.30.0.5/~/backups:
        Repository ID: ce767a46e144da4d5d77fc230418cb81eefc6cc6e34c9060e3dd6ef0b5e7fed3
        Location: ssh://cyb@172.30.0.5/~/backups
        Encrypted: Yes (repokey)
        Cache: /home/cyb/.cache/borg/ce767a46e144da4d5d77fc230418cb81eefc6cc6e34c9060e3dd6ef0b5e7fed3
        Security dir: /home/cyb/.config/borg/security/ce767a46e144da4d5d77fc230418cb81eefc6cc6e34c9060e3dd6ef0b5e7fed3
        ------------------------------------------------------------------------------
                            Original size      Compressed size    Deduplicated size
        All archives:              112.62 MB            112.50 MB            112.51 MB

                            Unique chunks         Total chunks
        Chunk index:                      59                   59
        ```

8. Add a file test.txt with as content Hello world. Create another backup, make sure it is called second. You should see a similar output as the following:

    ```bash
    [vagrant@web ~]$ borg list vagrant@172.30.20.15:~/backups
    Enter passphrase for key ssh://vagrant@172.30.20.15/~/backups:
    first                                Sat, 2023-11-04 14:14:34 [1823882f3d5f38983cd0f34379cb3d9ac724305ee44fbeda047babf14f05578c]
    second                               Sat, 2023-11-04 14:56:02 [604151f437b6f36095b45478704cd8b876af357fbda8c9971d5a5d86abb61d39]
    ```

    ```bash
    [vagrant@web ~]$ borg list vagrant@172.30.20.15:~/backups::first
    Enter passphrase for key ssh://vagrant@172.30.20.15/~/backups:
    drwxr-xr-x vagrant vagrant        0 Sat, 2023-11-04 12:45:54 home/vagrant/important-files
    -rw-r--r-- vagrant vagrant 110916740 Sat, 2023-11-04 12:44:55 home/vagrant/important-files/bf1f3fb5-b119-4f9f-9930-8e20e892b898-720.mp4
    -rw-r--r-- vagrant vagrant  5638841 Sat, 2023-11-04 12:45:00 home/vagrant/important-files/100.txt
    -rw-r--r-- vagrant vagrant  2391726 Sat, 2023-11-04 12:45:02 home/vagrant/important-files/996.txt
    -rw-r--r-- vagrant vagrant  1702187 Sat, 2023-11-04 12:45:02 home/vagrant/important-files/Toreador_song_cleaned.ogg
    ```

    ```bash
    [vagrant@web ~]$ borg list vagrant@172.30.20.15:~/backups::second
    Enter passphrase for key ssh://vagrant@172.30.20.15/~/backups:
    drwxr-xr-x vagrant vagrant        0 Sat, 2023-11-04 14:55:42 home/vagrant/important-files
    -rw-r--r-- vagrant vagrant 110916740 Sat, 2023-11-04 12:44:55 home/vagrant/important-files/bf1f3fb5-b119-4f9f-9930-8e20e892b898-720.mp4
    -rw-r--r-- vagrant vagrant  5638841 Sat, 2023-11-04 12:45:00 home/vagrant/important-files/100.txt
    -rw-r--r-- vagrant vagrant  2391726 Sat, 2023-11-04 12:45:02 home/vagrant/important-files/996.txt
    -rw-r--r-- vagrant vagrant  1702187 Sat, 2023-11-04 12:45:02 home/vagrant/important-files/Toreador_song_cleaned.ogg
    -rw-r--r-- vagrant vagrant       13 Sat, 2023-11-04 14:55:42 home/vagrant/important-files/test.txt
    ```

    ```bash
    [vagrant@web ~]$ borg info vagrant@172.30.20.15:~/backups
    Enter passphrase for key ssh://vagrant@172.30.20.15/~/backups:
    Repository ID: ff07eea40b0e6aadec34a7d1a31d6ea642efb2680241b0daacb7c118ba5805ed
    Location: ssh://vagrant@172.30.20.15/~/backups
    Encrypted: Yes (repokey)
    Cache: /home/vagrant/.cache/borg/ff07eea40b0e6aadec34a7d1a31d6ea642efb2680241b0daacb7c118ba5805ed
    Security dir: /home/vagrant/.config/borg/security/ff07eea40b0e6aadec34a7d1a31d6ea642efb2680241b0daacb7c118ba5805ed
    ------------------------------------------------------------------------------
                        Original size      Compressed size    Deduplicated size
    All archives:              241.30 MB            234.99 MB            117.50 MB

                        Unique chunks         Total chunks
    Chunk index:                      62                  119
    ```

    - My output

        ```bash
        [cyb@web ~]$ echo "Hello world" > ~/important-files/test.txt
        
        [cyb@web ~]$ borg create --progress ssh://cyb@172.30.0.5/~/backups::second ~/important-files
        Enter passphrase for key ssh://cyb@172.30.0.5/~/backups:
        
        [cyb@web ~]$ borg list ssh://cyb@172.30.0.5/~/backups
        Enter passphrase for key ssh://cyb@172.30.0.5/~/backups:
        first                                Sat, 2024-08-10 17:35:44 [a2221fe5aab75144683c50afeeed75d741288db28d7a2c347f700d1dfe4c8361]
        second                               Sat, 2024-08-10 19:15:35 [e50edb259d83fe1bd5b21676afe87b1d48f79c24aedec51183521ba9223129d8]
        
        [cyb@web ~]$ borg list ssh://cyb@172.30.0.5/~/backups::first
        Enter passphrase for key ssh://cyb@172.30.0.5/~/backups:
        drwxr-xr-x cyb    cyb           0 Sat, 2024-08-10 16:57:36 home/cyb/important-files
        -rw-r--r-- cyb    cyb    110916740 Sat, 2024-08-10 16:57:11 home/cyb/important-files/bf1f3fb5-b119-4f9f-9930-8e20e892b898-720.mp4
        -rw-r--r-- cyb    cyb         300 Sat, 2024-08-10 16:57:11 home/cyb/important-files/100.txt
        -rw-r--r-- cyb    cyb         300 Sat, 2024-08-10 16:57:11 home/cyb/important-files/996.txt
        -rw-r--r-- cyb    cyb     1702187 Sat, 2024-08-10 16:57:12 home/cyb/important-files/Toreador_song_cleaned.ogg
        
        [cyb@web ~]$ borg list ssh://cyb@172.30.0.5/~/backups::second
        Enter passphrase for key ssh://cyb@172.30.0.5/~/backups:
        drwxr-xr-x cyb    cyb           0 Sat, 2024-08-10 19:15:21 home/cyb/important-files
        -rw-r--r-- cyb    cyb          12 Sat, 2024-08-10 19:15:21 home/cyb/important-files/test.txt
        -rw-r--r-- cyb    cyb    110916740 Sat, 2024-08-10 16:57:11 home/cyb/important-files/bf1f3fb5-b119-4f9f-9930-8e20e892b898-720.mp4
        -rw-r--r-- cyb    cyb         300 Sat, 2024-08-10 16:57:11 home/cyb/important-files/100.txt
        -rw-r--r-- cyb    cyb         300 Sat, 2024-08-10 16:57:11 home/cyb/important-files/996.txt
        -rw-r--r-- cyb    cyb     1702187 Sat, 2024-08-10 16:57:12 home/cyb/important-files/Toreador_song_cleaned.ogg

        [cyb@web ~]$ borg info ssh://cyb@172.30.0.5/~/backups
        Enter passphrase for key ssh://cyb@172.30.0.5/~/backups:
        Repository ID: ce767a46e144da4d5d77fc230418cb81eefc6cc6e34c9060e3dd6ef0b5e7fed3
        Location: ssh://cyb@172.30.0.5/~/backups
        Encrypted: Yes (repokey)
        Cache: /home/cyb/.cache/borg/ce767a46e144da4d5d77fc230418cb81eefc6cc6e34c9060e3dd6ef0b5e7fed3
        Security dir: /home/cyb/.config/borg/security/ce767a46e144da4d5d77fc230418cb81eefc6cc6e34c9060e3dd6ef0b5e7fed3
        ------------------------------------------------------------------------------
                            Original size      Compressed size    Deduplicated size
        All archives:              225.24 MB            225.01 MB            112.51 MB

                            Unique chunks         Total chunks
        Chunk index:                      62                  119
        ```

9. It is necessary to periodically check the integrity of the borg repository. With which command can this be done? When should I use the --verify-data option? Tip: use --verbose to see more information.
    - See if backups are consistent and not corrupted. You can check this with the following command

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
        [cyb@web ~]$
        ```

    - `--verify-data` will not only check the integrity of the repository, but also the integrity of the data itself. This will take a lot longer, but is recommended to do every once in a while.

        ```bash
        [cyb@web ~]$ borg check --verify-data --verbose ssh://cyb@172.30.0.5/~/backups
        Remote: Starting repository check
        Remote: finished segment check at segment 9
        Remote: Starting repository index check
        Remote: Index object count match.
        Remote: Finished full repository check, no problems found.
        Starting archive consistency check...
        Enter passphrase for key ssh://cyb@172.30.0.5/~/backups:
        Starting cryptographic data integrity verification...
        Finished cryptographic data integrity verification, verified 63 chunks with 0 integrity errors.
        Analyzing archive first (1/2)
        Analyzing archive second (2/2)
        Archive consistency check complete, no problems found.
        ```

10. Delete the original files on web.

    ```bash
    [vagrant@web ~]$ rm --recursive --verbose important-files/
    removed 'important-files/bf1f3fb5-b119-4f9f-9930-8e20e892b898-720.mp4'
    removed 'important-files/100.txt'
    removed 'important-files/996.txt'
    removed 'important-files/Toreador_song_cleaned.ogg'
    removed directory 'important-files/'
    ```

11. Restore the original files using the first backup on the database server (without the test.txt file) to the same place on web so it seems like nothing has happened. --strip-elements may come in handy here as borg uses absolute paths inside backups. You should see a similar output after restoring the backup:

    ```bash
    [vagrant@web ~]$ ll important-files/
    total 117828
    -rw-r--r--. 1 vagrant vagrant   5638841 Nov  4 12:45 100.txt
    -rw-r--r--. 1 vagrant vagrant   2391726 Nov  4 12:45 996.txt
    -rw-r--r--. 1 vagrant vagrant   1702187 Nov  4 12:45 Toreador_song_cleaned.ogg
    -rw-r--r--. 1 vagrant vagrant 110916740 Nov  4 12:44 bf1f3fb5-b119-4f9f-9930-8e20e892b898-720.mp4
    ```

    - My output

        ```bash
        [cyb@web ~]$ ls
        borg_key.bak
        [cyb@web ~]$ borg extract --strip-components 2 ssh://cyb@172.30.0.5/~/backups::first ~/important-files
        Enter passphrase for key ssh://cyb@172.30.0.5/~/backups:
        [cyb@web ~]$ ll ~/important-files/
        total 109992
        -rw-r--r--. 1 cyb cyb       300 Aug 10 16:57 100.txt
        -rw-r--r--. 1 cyb cyb       300 Aug 10 16:57 996.txt
        -rw-r--r--. 1 cyb cyb   1702187 Aug 10 16:57 Toreador_song_cleaned.ogg
        -rw-r--r--. 1 cyb cyb 110916740 Aug 10 16:57 bf1f3fb5-b119-4f9f-9930-8e20e892b898-720.mp4
        [cyb@web ~]$
        ```

12. Automate the backups and set an appropriate retention policy. Look at the documentation to have a starting point. What is the retention policy here? Have you ever heard of the Grandfather-Father-Son policy? The automation should create a backup every 5 minutes. There are various ways to do this, but we prefer a systemd timer to execute the script on the time intervals.
    - Retention Policy: 20 backups for the last 2 years, 1 backup for every month for the last 2 years, 1 backup for every year for older backups. This means that the backups will be cleaned up automatically every time a new backup is made. This greatly reduces storage space.
    - The Grandfather-Father-Son policy is a retention policy that is often used in backup strategies. It is a rotation scheme that uses daily, weekly, and monthly backups. The ***daily*** backups are the **sons**, the ***weekly*** backups are the **fathers**, and the ***monthly*** backups are the **grandfathers**. The sons are kept for a week, the fathers for a month, and the grandfathers for a year. This way, you have a lot of backups that represent different snapshots in time of your data.  

    - Create a Backup Script `~/backup-script.sh``:

        ```bash
        #!/bin/bash

        # Define the repository location
        REPO="ssh://cyb@172.30.0.5/~/backups"

        # Create a new backup with the current date as the archive name
        borg create --stats --progress $REPO::"$(date +'%Y-%m-%d_%H-%M-%S')" ~/important-files

        # Prune old backups according to the retention policy
        borg prune --list $REPO --keep-daily=7 --keep-weekly=4 --keep-monthly=6
        ```

    - Make the script executable

        ```bash
        chmod +x ~/backup-script.sh
        ```

    - Create a Systemd Service file and timer for Automation 
      - `/etc/systemd/system/backup.service`:

        ```bash
        [Unit]
        Description=Backup Service

        [Service]
        Type=oneshot
        ExecStart=/home/cyb/backup-script.sh
        ```
  
        - `/etc/systemd/system/backup.timer`:

        ```bash
        [Unit]
        Description=Run Borg Backup Every 5 Minutes

        [Timer]
        OnCalendar=*:0/5
        Persistent=true

        [Install]
        WantedBy=timers.target
        ```

    - Enable and start the timer

        ```bash
        [cyb@web ~]$ sudo systemctl enable backup.timer
        Created symlink /etc/systemd/system/timers.target.wants/backup.timer → /etc/systemd/system/backup.timer.
        [cyb@web ~]$ sudo systemctl start backup.timer
        [cyb@web ~]$ systemctl status backup.timer
        ● backup.timer - Run Borg Backup Every 5 Minutes
            Loaded: loaded (/etc/systemd/system/backup.timer; enabled; preset: disabled)
            Active: active (waiting) since Sat 2024-08-10 19:44:40 UTC; 4s ago
            Until: Sat 2024-08-10 19:44:40 UTC; 4s ago
            Trigger: Sat 2024-08-10 19:45:00 UTC; 14s left
        Triggers: ● backup.service

        Aug 10 19:44:40 web systemd[1]: Started Run Borg Backup Every 5 Minutes.
        [cyb@web ~]$ systemctl list-timers --all
        NEXT                        LEFT          LAST                        PASSED       UNIT                         ACTIVATES
        Sat 2024-08-10 19:55:00 UTC 2min 26s left Sat 2024-08-10 19:50:01 UTC 2min 31s ago backup.timer                 backup.service
        Sat 2024-08-10 20:15:55 UTC 23min left    Sat 2024-08-10 19:03:59 UTC 48min ago    dnf-makecache.timer          dnf-makecache.service
        Sun 2024-08-11 00:00:00 UTC 4h 7min left  Sat 2024-08-10 06:20:23 UTC 13h ago      logrotate.timer              logrotate.service
        Sun 2024-08-11 17:30:20 UTC 21h left      Sat 2024-08-10 17:30:20 UTC 2h 22min ago systemd-tmpfiles-clean.timer systemd-tmpfiles-clean.service

        4 timers listed.
        ```

- What does the borg compact command do?
  - The borg compact command is used to optimize the space usage in your Borg repository. When you delete or prune old backups, Borg marks the data as unused, but the space is not immediately reclaimed. borg compact rewrites the repository segments to remove the unused data, effectively compacting the repository and reducing its size
  - Run borg compact periodically if you have pruned many archives, especially if you are noticing that the repository size is not shrinking after deleting old backups.

    ```bash
    [cyb@web ~]$ borg compact ssh://cyb@172.30.0.5/~/backups
    ```

### A brain teaser

- Can I use tools like borg to backup an active database? Why (not)? Read <https://borgbackup.readthedocs.io/en/stable/quickstart.html#important-note-about-files-changing-during-the-backup-process> for more information.
  - BorgBackup is not designed to handle live databases or other files that are actively being written to. The reason is that Borg does not lock files while backing them up, which means that if a file changes during the backup process, the backup could end up with a corrupted or inconsistent snapshot of that file.
  - There are two primary concerns when backing up active files with Borg:
    - File Changes During Backup:
      - If a file changes after Borg starts the backup process but before it completes reading the file, the backed-up version of the file might be in an inconsistent state.
    - Inconsistent State of the Database:
      - Databases often have complex relationships between files. If Borg backs up these files while the database is running, it might capture an inconsistent snapshot where some files reflect the state before a transaction and others reflect the state after.

- Should I take any extra measures to do this safely?
  - To safely back up an active database using Borg or similar tools, you should ensure the database files are in a consistent state when Borg reads them. Here are some common strategies:
    - Database Dump (use native database tools to create a consistent snapshot of the database, this is a static file that can be safely backed up by Borg)
    - Filesystem Snapshots (backup snapshots of the filesystem if the database supports it)
    - Pause Database Writes (if short downtime is acceptable)
    - Backup at Low Activity Times (reduce risk of file changes during backup)

- There is a tool that has been built on top of borg called **borgmatic**. What does it do? Could it be useful to you? Why (not)?
  - Borgmatic is a simple, automated way to manage Borg backups. It is essentially a wrapper around Borg, simplifying configuration and automation. Borgmatic provides additional features like:
    - Automating Backup Creation: You can configure backup schedules, pruning, and monitoring using a straightforward YAML configuration file.
    - Managing Retention Policies: Borgmatic makes it easier to define and apply retention policies.
    - Handling Alerts: Borgmatic can send notifications if something goes wrong with the backup process
  - Is it useful?
    - Yes, Borgmatic could be very useful, especially if you plan to automate backups and manage them over the long term
      - Easy to use
      - Automation
      - Notifications and Alerts

- Another more recent tool that can be used is **Restic**. Try the lab again with this tool. [^1]: Restic has support for Windows, but it is still in an early stage.

#### Restic

You can follow similar steps to those you used with Borg, but with Restic commands:

- Initialize a Repository

    ```bash
    restic init -r /path/to/repo
    ```

- Create a Backup:

    ```bash
    restic -r /path/to/repo backup /path/to/data
    ```

- List Snapshots:

    ```bash
    restic -r /path/to/repo snapshots
    ```

- Restore a Backup:

    ```bash
    restic -r /path/to/repo restore latest --target /restore/path
    ```

- Prune Old Backups:

    ```bash
    restic -r /path/to/repo forget --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune
    ```
