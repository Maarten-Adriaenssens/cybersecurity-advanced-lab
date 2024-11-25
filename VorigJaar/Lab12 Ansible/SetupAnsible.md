# Setup Ansible

## Ping Pong (on cyb@companyrouter)

```bash
ansible -i inventory.yml -m "win_ping" dc
ansible -i inventory.yml -m "win_shell" -a "hostname" dc
ansible -i inventory.yml -m "ping" linux
```

## Playbooks

### 1. Get date

```bash
ansible -i inventory.yml linux -m command -a "date"
ansible -i inventory.yml dc -m win_shell -a "Get-Date"
```

### 2. Pull /etc/passwd from all linux machines

```bash
ansible -i inventory.yml linux -m fetch -a "src=/etc/passwd dest=~/passwd_files/{{ inventory_hostname }}/passwd flat=yes"
```

### 3. Create user Walt

```bash
ansible-playbook -i inventory.yml create_user_walt.yml --ask-become-pass
```

### 4. list allowed user on linux

```bash
ansible-playbook -i inventory.yml list_login_users.yml
```

### 5. calculate hash of a binary (for example the ss binary)

```bash
ansible-playbook -i inventory.yml calculate_hash.yml
```

### 6. Windows Defender enabled?

```bash
ansible-playbook -i inventory.yml windows_defender.yml
```

### 7. Copies file from ansible to all linux machines

```bash
sudo nano /home/cyb/localfile.txt
ansible-playbook -i inventory.yml copy_file_to_linux.yml
```

### 8. Copies file from ansible to all WINDOWS machines

```bash
ansible-playbook -i inventory.yml copy_file_to_windows.yml
```