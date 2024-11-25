# Lab12 - Hunting and hardening with ansible

```powershell
PS C:\Users\Walt> New-LocalUser -Name "Ansible" -Password (ConvertTo-SecureString -AsPlainText "Friday13th!" -Force) -FullName "Ansible"
PS C:\Users\Walt> Add-LocalGroupMember -Group "Administrators" -Member "Ansible"


PS C:\Users\Walt> winrm quickconfig
WinRM service is already running on this machine.
WinRM is already set up for remote management on this computer.
PS C:\Users\Walt> winrm set winrm/config/service/auth '@{Basic="true"}'
Auth
    Basic = true
    Kerberos = true
    Negotiate = true
    Certificate = false
    CredSSP = false
    CbtHardeningLevel = Relaxed

PS C:\Users\Walt> winrm set winrm/config/service '@{AllowUnencrypted="true"}'
Service
    RootSDDL = O:NSG:BAD:P(A;;GA;;;BA)(A;;GR;;;IU)S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)
    MaxConcurrentOperations = 4294967295
    MaxConcurrentOperationsPerUser = 1500
    EnumerationTimeoutms = 240000
    MaxConnections = 300
    MaxPacketRetrievalTimeSeconds = 120
    AllowUnencrypted = true
    Auth
        Basic = true
        Kerberos = true
        Negotiate = true
        Certificate = false
        CredSSP = false
        CbtHardeningLevel = Relaxed
    DefaultPorts
        HTTP = 5985
        HTTPS = 5986
    IPv4Filter = *
    IPv6Filter = *
    EnableCompatibilityHttpListener = false
    EnableCompatibilityHttpsListener = false
    CertificateThumbprint
    AllowRemoteAccess = true
```

```bash
sudo adduser ansible
sudo passwd ansible
sudo usermod -aG wheel ansible

```


## Inventory.yaml

```yaml
[companyrouter]
localhost ansible_connection=ssh ansible_host=127.0.0.1 ansible_port=2222 ansible_user=ansible

[dc]
172.30.0.4:5985

[dc:vars]
ansible_user=cyb-dc
ansible_password=Friday13th!
ansible_connection=winrm
ansible_winrm_server_cert_validation=ignore

[web]
172.30.20.10 ansible_user=ansible ansible_connection=ssh ansible_port=22

[database]
172.30.0.5 ansible_user=ansible ansible_connection=ssh ansible_port=22

[linux]
localhost ansible_connection=ssh ansible_host=127.0.0.1 ansible_port=2222 ansible_user=ansible
172.30.20.10
172.30.0.5

[windowsclients]
172.30.100.100:5985

[windowsclients:vars]
ansible_user=Ansible
ansible_password=Friday13th!
ansible_connection=winrm
ansible_winrm_server_cert_validation=ignore
```

## After pings are completed

Configure and test out the following use cases. In theory you could do it on all systems but if you have memory issues limit the number of clients in your ansible command or in the inventory file.

1. Run an ad-hoc ansible command to check if the date of all machines are configured the same. Are you able to use the same Windows module for Linux machines and vice versa?
   - (Linux Machines)

    ```bash
    [cyb@companyrouter ansible]$ ansible -i inventory.yml linux -m command -a "date"
    172.30.0.5 | CHANGED | rc=0 >>
    Tue Aug 20 12:54:32 UTC 2024
    localhost | CHANGED | rc=0 >>
    Tue Aug 20 12:54:32 UTC 2024
    172.30.20.10 | CHANGED | rc=0 >>
    Tue Aug 20 12:54:33 UTC 2024
    ```

   - (Windows Machine)

    ```powershell
    [cyb@companyrouter ansible]$ ansible -i inventory.yml dc -m win_shell -a "Get-Date"
    172.30.0.4 | CHANGED | rc=0 >>

    Tuesday, August 20, 2024 2:56:43 PM
    [cyb@companyrouter ansible]$ ansible -i inventory.yml windowsclients -m win_shell -a "Get-Date"
    172.30.100.100 | CHANGED | rc=0 >>

    Tuesday, August 20, 2024 2:57:05 PM
    ```

2. Create a playbook (or ad-hoc command) that pulls all "/etc/passwd" files from all Linux machines locally to the ansible controller node for every machine seperately.

    ```bash
    [cyb@companyrouter ansible]$ ansible -i inventory.yml linux -m fetch -a "src=/etc/passwd dest=~/passwd_files/{{ inventory_hostname }}/passwd flat=yes"
    172.30.0.5 | CHANGED => {
        "changed": true,
        "checksum": "bb922c12aa9c855e6304200c12ee45f9b4e517b0",
        "dest": "/home/cyb/passwd_files/172.30.0.5/passwd",
        "md5sum": "e2b71f4bfc35af385637d2ba12f49540",
        "remote_checksum": "bb922c12aa9c855e6304200c12ee45f9b4e517b0",
        "remote_md5sum": null
    }
    172.30.20.10 | CHANGED => {
        "changed": true,
        "checksum": "d57befd3d974468949954bf5ee6ec0cbbd9ce121",
        "dest": "/home/cyb/passwd_files/172.30.20.10/passwd",
        "md5sum": "0b40572b2d55269620cca9ed8f7dbd48",
        "remote_checksum": "d57befd3d974468949954bf5ee6ec0cbbd9ce121",
        "remote_md5sum": null
    }
    localhost | CHANGED => {
        "changed": true,
        "checksum": "088c2e26cd4ac64576e83e4a18ac371f24d2ad01",
        "dest": "/home/cyb/passwd_files/localhost/passwd",
        "md5sum": "5d4ab276faf7ca88b363a269774ce90a",
        "remote_checksum": "088c2e26cd4ac64576e83e4a18ac371f24d2ad01",
        "remote_md5sum": null
    }
    [cyb@companyrouter ansible]$ ansible -i inventory.yml linux -m fetch -a "src=/etc/passwd dest=~/passwd_files/{{ inventory_hostname }}/passwd flat=yes"
    172.30.0.5 | SUCCESS => {
        "changed": false,
        "checksum": "bb922c12aa9c855e6304200c12ee45f9b4e517b0",
        "dest": "/home/cyb/passwd_files/172.30.0.5/passwd",
        "file": "/etc/passwd",
        "md5sum": "e2b71f4bfc35af385637d2ba12f49540"
    }
    localhost | SUCCESS => {
        "changed": false,
        "checksum": "088c2e26cd4ac64576e83e4a18ac371f24d2ad01",
        "dest": "/home/cyb/passwd_files/localhost/passwd",
        "file": "/etc/passwd",
        "md5sum": "5d4ab276faf7ca88b363a269774ce90a"
    }
    172.30.20.10 | SUCCESS => {
        "changed": false,
        "checksum": "d57befd3d974468949954bf5ee6ec0cbbd9ce121",
        "dest": "/home/cyb/passwd_files/172.30.20.10/passwd",
        "file": "/etc/passwd",
        "md5sum": "0b40572b2d55269620cca9ed8f7dbd48"
    }
    ```

3. Create a playbook (or ad-hoc command) that creates the user "walt" with password "Friday13th!" on all Linux machines.

   - Zonder Sudo paswoord.

    ```yaml
   - hosts: linux
     become: yes
     tasks:
       - name: Create user walt
         user:
           name: walt
           password: "{{ 'Friday13th!' | password_hash('sha512') }}"
           state: present
    ```

    ```bash
    [cyb@companyrouter ansible]$ ansible-playbook -i inventory.yml create_user_walt.yml --ask-become-pass
    BECOME password: Friday13th!

    PLAY [linux] ****************************************************************************************************

    TASK [Gathering Facts] ******************************************************************************************
    ok: [172.30.0.5]
    ok: [172.30.20.10]
    ok: [localhost]

    TASK [Create user walt] *****************************************************************************************
    [DEPRECATION WARNING]: Encryption using the Python crypt module is deprecated. The Python crypt module is
    deprecated and will be removed from Python 3.13. Install the passlib library for continued encryption
    functionality. This feature will be removed in version 2.17. Deprecation warnings can be disabled by setting
    deprecation_warnings=False in ansible.cfg.
    [DEPRECATION WARNING]: Encryption using the Python crypt module is deprecated. The Python crypt module is
    deprecated and will be removed from Python 3.13. Install the passlib library for continued encryption
    functionality. This feature will be removed in version 2.17. Deprecation warnings can be disabled by setting
    deprecation_warnings=False in ansible.cfg.
    [DEPRECATION WARNING]: Encryption using the Python crypt module is deprecated. The Python crypt module is
    deprecated and will be removed from Python 3.13. Install the passlib library for continued encryption
    functionality. This feature will be removed in version 2.17. Deprecation warnings can be disabled by setting
    deprecation_warnings=False in ansible.cfg.
    changed: [localhost]
    changed: [172.30.20.10]
    changed: [172.30.0.5]

    PLAY RECAP ******************************************************************************************************
    172.30.0.5                 : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    172.30.20.10               : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    localhost                  : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    ```

    Kan ook gehardcode in code worden:

    ```yaml
    ---
   - hosts: linux
     become: yes
     become_method: sudo
     become_user: root
     vars:
       ansible_become_pass: 'Friday13th!'
     tasks:
       - name: Create user walt
         user:
           name: walt
           password: "{{ 'Friday13th!' | password_hash('sha512') }}"
           state: present

    ```

4. Create a playbook (or ad-hoc command) that pulls all users that are allowed to log in on all Linux machines.

    ```yaml
    ---
    - hosts: linux
    become: yes
    become_method: sudo
    become_user: root
    vars:
        ansible_become_pass: 'Friday13th!'
    tasks:
        - name: List all users allowed to log in
        shell: getent passwd | grep '/bin/bash\|/bin/sh'
        register: login_users

        - name: Print login users
        debug:
            var: login_users.stdout_lines
    ```

   ```bash
    [cyb@companyrouter ansible]$ ansible-playbook -i inventory.yml list_login_users.yml

    PLAY [linux] ****************************************************************************************

    TASK [Gathering Facts] ******************************************************************************
    ok: [172.30.0.5]
    ok: [172.30.20.10]
    ok: [localhost]

    TASK [List all users allowed to log in] *************************************************************
    changed: [172.30.0.5]
    changed: [localhost]
    changed: [172.30.20.10]

    TASK [Print login users] ****************************************************************************
    ok: [localhost] => {
        "login_users.stdout_lines": [
            "root:x:0:0:root:/root:/bin/bash",
            "vagrant:x:1000:1000::/home/vagrant:/bin/bash",
            "companyrouter:x:1001:1001::/home/companyrouter:/bin/bash",
            "cyb:x:1002:1002::/home/cyb:/bin/bash",
            "ansible:x:1003:1003::/home/ansible:/bin/bash",
            "walt:x:1004:1004::/home/walt:/bin/bash"
        ]
    }
    ok: [172.30.20.10] => {
        "login_users.stdout_lines": [
            "root:x:0:0:root:/root:/bin/bash",
            "vagrant:x:1000:1000::/home/vagrant:/bin/bash",
            "cyb:x:1001:1001::/home/cyb:/bin/bash",
            "ansible:x:1002:1002::/home/ansible:/bin/bash",
            "walt:x:1003:1003::/home/walt:/bin/bash"
        ]
    }
    ok: [172.30.0.5] => {
        "login_users.stdout_lines": [
            "root:x:0:0:root:/root:/bin/bash",
            "vagrant:x:1000:1000::/home/vagrant:/bin/bash",
            "cyb:x:1001:1001::/home/cyb:/bin/bash",
            "ansible:x:1002:1002::/home/ansible:/bin/bash",
            "walt:x:1003:1003::/home/walt:/bin/bash"
        ]
    }

    PLAY RECAP ******************************************************************************************
    172.30.0.5                 : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    172.30.20.10               : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    localhost                  : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    ```

5. Create a playbook (or ad-hoc command) that calculates the hash (md5sum for example) of a binary (for example the ss binary).

    ```yaml
    ---
    - hosts: linux
    become: yes
    become_method: sudo
    become_user: root
    vars:
        ansible_become_pass: 'Friday13th!'
    tasks:
        - name: Check if /usr/sbin/ss exists
        stat:
            path: /usr/sbin/ss
        register: ss_file

        - name: Calculate md5sum of /usr/sbin/ss
        command: md5sum /usr/sbin/ss
        when: ss_file.stat.exists
        register: ss_hash

        - name: Print the hash of /usr/sbin/ss
        debug:
            var: ss_hash.stdout
        when: ss_file.stat.exists
    ```

    ```bash
    [cyb@companyrouter ansible]$ ansible-playbook -i inventory.yml calculate_hash.yml

    PLAY [linux] ****************************************************************************************

    TASK [Gathering Facts] ******************************************************************************
    ok: [172.30.0.5]
    ok: [localhost]
    ok: [172.30.20.10]

    TASK [Check if /usr/sbin/ss exists] *****************************************************************
    ok: [172.30.0.5]
    ok: [localhost]
    ok: [172.30.20.10]

    TASK [Calculate md5sum of /usr/sbin/ss] *************************************************************
    changed: [localhost]
    changed: [172.30.0.5]
    changed: [172.30.20.10]

    TASK [Print the hash of /usr/sbin/ss] ***************************************************************
    ok: [localhost] => {
        "ss_hash.stdout": "0e29cedd88229b39df3dd5b636344782  /usr/sbin/ss"
    }
    ok: [172.30.20.10] => {
        "ss_hash.stdout": "e13b63ecba3a94e56fe72ad4128757d5  /usr/sbin/ss"
    }
    ok: [172.30.0.5] => {
        "ss_hash.stdout": "e13b63ecba3a94e56fe72ad4128757d5  /usr/sbin/ss"
    }

    PLAY RECAP ******************************************************************************************
    172.30.0.5                 : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    172.30.20.10               : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    localhost                  : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    ```

6. Create a playbook (or ad-hoc command) that shows if Windows Defender is enabled and if there are any folder exclusions configured on the Windows client. This might require a bit of searching on how to retrieve this information 
through a command/PowerShell.

    ```yaml
    ---
   - hosts: windowsclients
     tasks:
       - name: Check if Windows Defender is enabled and list exclusions
         win_shell: |
           $defenderStatus = Get-MpPreference | Select-Object -Property DisableRealtimeMonitoring, ExclusionPath
           $defenderStatus
         register: defender_status

       - name: Print Windows Defender status and exclusions
         debug:
           var: defender_status.stdout_lines

    ```

    ```bash
    [cyb@companyrouter ansible]$ ansible-playbook -i inventory.yml windows_defender.yml

    PLAY [windowsclients] *******************************************************************************

    TASK [Gathering Facts] ******************************************************************************
    ok: [172.30.100.100]

    TASK [Check if Windows Defender is enabled and list exclusions] *************************************
    changed: [172.30.100.100]

    TASK [Print Windows Defender status and exclusions] *************************************************
    ok: [172.30.100.100] => {
        "defender_status.stdout_lines": [
            "",
            "DisableRealtimeMonitoring ExclusionPath",
            "------------------------- -------------",
            "                    False {c:\\}        ",
            "",
            ""
        ]
    }

    PLAY RECAP ******************************************************************************************
    172.30.100.100             : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    ```

7. Create a playbook (or ad-hoc command) that copies a file (for example a txt file) from the ansible controller machine to all Linux machines.

    ```yaml
    ---
   - hosts: linux
     become: yes
     become_method: sudo
     become_user: root
     vars:
       ansible_become_pass: 'Friday13th!'
     tasks:
       - name: Copy file to all Linux machines
         copy:
           src: /path/to/localfile.txt
           dest: /tmp/remote_file.txt
    ```

    ```bash
    [cyb@companyrouter ansible]$ sudo nano /home/cyb/localfile.txt
    [cyb@companyrouter ansible]$ ansible-playbook -i inventory.yml copy_file_to_linux.yml

    PLAY [linux] ****************************************************************************************

    TASK [Gathering Facts] ******************************************************************************
    ok: [172.30.0.5]
    ok: [localhost]
    ok: [172.30.20.10]

    TASK [Copy file to all Linux machines] **************************************************************
    changed: [localhost]
    changed: [172.30.0.5]
    changed: [172.30.20.10]

    PLAY RECAP ******************************************************************************************
    172.30.0.5                 : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    172.30.20.10               : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    localhost                  : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    ```

8. Create the same as 7 but for Windows machines.

    ```yaml
    ---
    - hosts: windowsclients
    tasks:
        - name: Ensure destination directory exists
        win_file:
            path: C:\temp
            state: directory

        - name: Copy file to all Windows machines
        win_copy:
            src: /home/cyb/localfile.txt
            dest: C:\temp\remote_file.txt    
    ```

    ```bash
    [cyb@companyrouter ansible]$ ansible-playbook -i inventory.yml copy_file_to_windows.yml

    PLAY [windowsclients] *******************************************************************************
    TASK [Gathering Facts] ******************************************************************************
    ok: [172.30.100.100]

    TASK [Ensure destination directory exists] **********************************************************
    changed: [172.30.100.100]

    TASK [Copy file to all Windows machines] ************************************************************
    changed: [172.30.100.100]

    PLAY RECAP ******************************************************************************************
    172.30.100.100             : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    ```