# Basic Configuration of all machines

## Change Keyboard on Red Machine

### Directly Edit Configuration Files

Edit the /etc/default/keyboard file to set the Belgian keyboard layout. Open this file with a text editor, such as nano:
bash

```linux
sudo nano /etc/default/keyboard
```

Modify the file to look like this:

```bash
XKBMODEL="pc105"
XKBLAYOUT="be"
XKBVARIANT=""
XKBOPTIONS=""
BACKSPACE="guess"
```

Apply Changes:

After editing the file, apply the changes using the following commands:
bash

```linux
sudo setupcon
sudo service keyboard-setup restart
```

## SSH Username

### Step 1: Ensure SSH Server is Installed on the Red Machine

Install OpenSSH Server:
On the "red" virtual machine, install the OpenSSH server if it is not already installed:

```bash
sudo apt update
sudo apt install openssh-server -y
```

Start and Enable SSH Service:
Start the SSH service and enable it to start on boot:

```bash
sudo systemctl start ssh
sudo systemctl enable ssh
```

Verify SSH Service:
Check if the SSH service is running:

```bash
sudo systemctl status ssh
```

### Step 2: Find the IP Address of the Red Machine

Check IP Address:
On the "red" virtual machine, find the IP address assigned by the host-only adapter:
bash
Copy code
ip a
Look for the IP address under the enp0s3 interface. For example, 192.168.100.102.

### Step 3: SSH from Host to Red Machine

Open Terminal on Host Machine:
Open a terminal on your host machine.

SSH into Red Machine:
Use the SSH command to connect to the "red" machine. Replace your_username with the username you use on the "red" machine, and 192.168.100.102 with the IP address of the "red" machine:

```bash
ssh red@192.168.100.102

```
