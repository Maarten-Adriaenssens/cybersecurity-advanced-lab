# Lab05 - Honeypots 

## Cowrie

This lab introduces the implementation of a honeypot.

As defined by Kaspersky ( <https://www.kaspersky.com/resource-center/threats/what-is-a-honeypot> ) a honeypot in cyber security is typically a system or service that acts like a decoy to lure hackers. It mimics a target for hackers in such a way that evildoers think they found "a way in" only to waste time. The most interesting part of a good honeypot is the logging and monitoring. By observing, a good blue teamer can take actions accordingly (for example ban a specific IP or remove specific commands).

Let's test this out by creating a SSH honeypot on companyrouter using <https://github.com/cowrie/cowrie>.

You are free to install this tool in any way you see fit. Docker is probably the easiest way to get things up and running but you are free to choose.

Steps:

1. Why is companyrouter, in this environment, an interesting device to configure with a SSH honeypot? What could be a good argument to NOT configure the router with a honeypot service?
   - Companyrouter is central device in network topology. It sees traffic from various zones.
   - If the attacker knows it's a trap, he/ she could try to find the real entry points. Or maybe the honeypot itself is vulnerable
   - Resource Usage

2. Change your current SSH configuration in such a way that the SSH server (daemon) is not listening on port 22 anymore but on port 2222.
   - Edit the SSH Configuration:

    ```bash
    sudo nano /etc/ssh/sshd_config
    ```

   - Find the line that says `#Port 22` and change it to `Port 2222` (uncomment)
   - Restart the SSH Daemon `sudo systemctl restart sshd`.
     - `sudo getenforce`, If SELinux is enforcing, try setting it to permissive mode temporarily to test `sudo setenforce 0`
   - Doordat de companyrouter een jump bastion is. Zal dit gespecifieerd moeten worden in ~.ssh/config hierdoor kan je terug ssh'en naar: isprouter, web, database, dc, win10.

    ```yaml
    Host companyrouter
        HostName 192.168.100.253
        User cyb
        IdentityFile C:\Users\JensV\.ssh\id_rsa
        Port 2222
    ```

3. Install and run the cowrie software on the router and listen on port 22 - the default SSH server port.
   - Install Cowrie manually

        ```bash
        sudo yum install -y python3 python3-venv python3-devel gcc git
        git clone https://github.com/cowrie/cowrie.git
        cd cowrie
        python3 -m venv cowrie-env
        source cowrie-env/bin/activate
        pip install --upgrade pip
        pip install -r requirements.txt
        cp etc/cowrie.cfg.dist etc/cowrie.cfg
        nano etc/cowrie.cfg
        ```

        - Edit the configuration file to listen on port 22

        ```ini
        [honeypot]
        hostname = cyb
        prompt = cyb@[companyrouter]:
        filesystem_file = honeyfs/opt/blackarch/profiles/cowrie_fs.pickle
        shell = /bin/bash

        [ssh]
        enabled = true
        listen_endpoints = tcp:22:interface=0.0.0.0
        auth_class = UserDB
        userdb = etc/userdb.txt
        ```

        - Create a user database

        ```bash
        cp etc/userdb.example etc/userdb.txt
        nano etc/userdb.txt

        cyb:$6$kUyh8ralbu.W/4WW$AVxbyQpQeKRqL13HLTuUrzGeaYeDpa3dbvYUngDo7tJvtLXFldh59Se72jVHmXA4d4tcUuwoqIy6bt9XIQHf8.:1000:1000::/home/cyb:/bin/bash

        ```

      - Start Cowrie

        ```bash
        bin/cowrie start
        ss -tuln | grep 22
        ```

   - Install Cowrie with docker (Optional)

    ```bash
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum install docker-ce docker-ce-cli containerd.io -y
    sudo systemctl start docker
    sudo systemctl enable docker
    ```

    - Run the Cowrie Docker Container
    - This command sets up Cowrie to listen on port 22 of your router, mapping it to port 2222 inside the container where the actual Cowrie service runs.

     ```bash
     sudo docker run -d --name cowrie -p 22:2222 cowrie/cowrie
    ```

4. Once configured and up and running, verify that you can still SSH to the router normally, using port 2222.
   - See if you can still connect to the router using the new port

    ```powershell
    PS C:\Users\JensV> ssh -p 2222 companyrouter
    Last login: Fri Aug  9 15:28:06 2024 from 192.168.100.1
    [cyb@companyrouter ~]$
    ```

   - If you get a warning about the authenticity of the host, you can remove the old key from your known_hosts file using `ssh-keygen -R <IP>`. (so you'll see what a new user would see)

    ```powershell
    PS C:\Users\JensV> ssh-keygen -R 192.168.100.253
    # Host 192.168.100.253 found: line 7
    # Host 192.168.100.253 found: line 8
    # Host 192.168.100.253 found: line 9
    C:\Users\JensV/.ssh/known_hosts updated.
    Original contents retained as C:\Users\JensV/.ssh/known_hosts.old
    PS C:\Users\JensV> ssh companyrouter
    The authenticity of host '192.168.100.253 (192.168.100.253)' can't be established.
    ED25519 key fingerprint is SHA256:KKNk6vb0odS2KWCWAKTrM+Dhjrb9u2MkhSkwGGn6Mjs.
    This key is not known by any other names
    Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
    Warning: Permanently added '192.168.100.253' (ED25519) to the list of known hosts.
    cyb@192.168.100.253's password:
    Permission denied, please try again.
    cyb@192.168.100.253's password:
    Permission denied, please try again.
    cyb@192.168.100.253's password:
    cyb@192.168.100.253: Permission denied (publickey,password).
    ```

    - This can now be traced in the Cowrie logs.

    ```bash
    [cyb@companyrouter ~]$ sudo docker logs cowrie
    2024-08-09T15:44:22+0000 [cowrie.ssh.factory.CowrieSSHFactory] No moduli, no diffie-hellman-group-exchange-sha1
    2024-08-09T15:44:22+0000 [cowrie.ssh.factory.CowrieSSHFactory] No moduli, no diffie-hellman-group-exchange-sha256
    2024-08-09T15:44:22+0000 [cowrie.ssh.factory.CowrieSSHFactory] New connection: 192.168.100.1:57826 (172.17.0.2:2222) [session: c4ced1a15ca7]
    2024-08-09T15:44:22+0000 [HoneyPotSSHTransport,5,192.168.100.1] Remote SSH version: SSH-2.0-OpenSSH_for_Windows_8.6
    2024-08-09T15:44:22+0000 [HoneyPotSSHTransport,5,192.168.100.1] SSH client hassh fingerprint: ae8bd7dd09970555aa4c6ed22adbbf56
    2024-08-09T15:44:22+0000 [cowrie.ssh.transport.HoneyPotSSHTransport#debug] kex alg=b'curve25519-sha256' key alg=b'ssh-ed25519'
    2024-08-09T15:44:22+0000 [cowrie.ssh.transport.HoneyPotSSHTransport#debug] outgoing: b'aes128-ctr' b'hmac-sha2-256' b'none'
    2024-08-09T15:44:22+0000 [cowrie.ssh.transport.HoneyPotSSHTransport#debug] incoming: b'aes128-ctr' b'hmac-sha2-256' b'none'
    2024-08-09T15:44:22+0000 [cowrie.ssh.transport.HoneyPotSSHTransport#debug] NEW KEYS
    2024-08-09T15:44:22+0000 [cowrie.ssh.transport.HoneyPotSSHTransport#debug] starting service b'ssh-userauth'
    2024-08-09T15:44:22+0000 [cowrie.ssh.userauth.HoneyPotSSHUserAuthServer#debug] b'cyb' trying auth b'none'
    2024-08-09T15:44:22+0000 [cowrie.ssh.userauth.HoneyPotSSHUserAuthServer#debug] b'cyb' trying auth b'publickey'
    2024-08-09T15:44:22+0000 [HoneyPotSSHTransport,5,192.168.100.1] public key attempt for user b'cyb' of type b'ssh-rsa' with fingerprint 60:7f:ca:b0:52:01:cd:06:e0:df:b6:59:b2:32:a4:f1
    2024-08-09T15:44:22+0000 [cowrie.ssh.userauth.HoneyPotSSHUserAuthServer#debug] b'cyb' failed auth b'publickey'
    2024-08-09T15:44:22+0000 [cowrie.ssh.userauth.HoneyPotSSHUserAuthServer#debug] reason: ('Incorrect signature', None)
    2024-08-09T15:44:25+0000 [cowrie.ssh.userauth.HoneyPotSSHUserAuthServer#debug] b'cyb' trying auth b'password'
    2024-08-09T15:44:25+0000 [HoneyPotSSHTransport,5,192.168.100.1] Could not read etc/userdb.txt, default database activated
    2024-08-09T15:44:25+0000 [HoneyPotSSHTransport,5,192.168.100.1] login attempt [b'cyb'/b'Friday13th!'] failed
    2024-08-09T15:44:26+0000 [cowrie.ssh.userauth.HoneyPotSSHUserAuthServer#debug] b'cyb' failed auth b'password'
    2024-08-09T15:44:26+0000 [cowrie.ssh.userauth.HoneyPotSSHUserAuthServer#debug] unauthorized login: ()
    2024-08-09T15:44:33+0000 [cowrie.ssh.userauth.HoneyPotSSHUserAuthServer#debug] b'cyb' trying auth b'password'
    2024-08-09T15:44:33+0000 [HoneyPotSSHTransport,5,192.168.100.1] Could not read etc/userdb.txt, default database activated
    2024-08-09T15:44:33+0000 [HoneyPotSSHTransport,5,192.168.100.1] login attempt [b'cyb'/b'DitIsEenPasswoord'] failed
    2024-08-09T15:44:34+0000 [cowrie.ssh.userauth.HoneyPotSSHUserAuthServer#debug] b'cyb' failed auth b'password'
    2024-08-09T15:44:34+0000 [cowrie.ssh.userauth.HoneyPotSSHUserAuthServer#debug] unauthorized login: ()
    2024-08-09T15:44:34+0000 [cowrie.ssh.userauth.HoneyPotSSHUserAuthServer#debug] b'cyb' trying auth b'password'
    2024-08-09T15:44:34+0000 [HoneyPotSSHTransport,5,192.168.100.1] Could not read etc/userdb.txt, default database activated
    2024-08-09T15:44:34+0000 [HoneyPotSSHTransport,5,192.168.100.1] login attempt [b'cyb'/b'kali'] failed
    2024-08-09T15:44:35+0000 [cowrie.ssh.userauth.HoneyPotSSHUserAuthServer#debug] b'cyb' failed auth b'password'
    2024-08-09T15:44:35+0000 [cowrie.ssh.userauth.HoneyPotSSHUserAuthServer#debug] unauthorized login: ()
    2024-08-09T15:44:35+0000 [cowrie.ssh.transport.HoneyPotSSHTransport#info] connection lost
    2024-08-09T15:44:35+0000 [HoneyPotSSHTransport,5,192.168.100.1] Connection lost after 13 seconds
    ```

5. Attack your router and try to SSH normally. What do you notice?
   - What credentials work? Do you find credentials that don't work?
     - None of the credentials work. Cowrie is a honeypot and does not have a real user database. It only logs the attempts.
   - Do you get a shell?
     - No, Even if the credentials were correct, Cowrie would provide a fake shell environment designed to simulate a real system.
   - Are your commands logged? Is the IP address of the SSH client logged? If this is the case, where?
     - Yes, the commands are logged. The IP address of the SSH client is logged in the Cowrie logs.(Output above shows the IP address of the client in an attempt to login)
   - Can an attacker perform malicious things?
     - No real damage, responses are fake
   - Are the actions, in other words the commands, logged to a file? Which file?
     - Yes, all actions are logged to the Cowrie logs. The logs are stored in the Docker container. You can view them using `sudo docker logs cowrie` or in `/var/log/cowrie/cowrie.log` on the host machine (companyrouter).
   - If you are an experienced hacker, how would/can you realize this is not a normal environment?

## Critical thinking (security) when using "Docker as a service"

If you decided to run cowrie by using a docker container, you've made the decision to use docker as a "deployment method" of a service or application. Some people in the industry refer to this phenomena as "docker as a service". Try to think, research and answer the following questions when it comes to running services, daemons and programs using docker:

- What are some (at least 2) advantages of running services (for example cowrie but it could be sql server as well) using docker?
  - Docker provides a lightweight form of isolation, allowing you to run services like Cowrie in a contained environment separate from the host system.
  - Portability: Docker containers can run on any system that supports Docker, regardless of the underlying hardware or operating system.
  - Ease of Deployment: Docker simplifies the deployment process. You can package all the dependencies and configurations of a service into a single container.
- What could be a disadvantage? Give at least 1.
  - Security Concerns: Containers share the same kernel as the host system, meaning a vulnerability in Docker or a misconfigured container could potentially lead to an attacker gaining access to the host system. This is less of a concern with virtual machines (VMs), which have a more isolated environment.
- Explain what is meant with "Docker uses a client-server architecture."
  - Docker's architecture consists of a client and a server. The client is the Docker command-line tool (docker), which users interact with to manage containers. The server is the Docker daemon (dockerd), which is responsible for building, running, and managing Docker containers. The client and server can run on the same system, or the client can connect to a Docker daemon running on a remote host.
- As which user is the docker daemon running by default? Tip: <https://docs.docker.com/engine/install/linux-postinstall/> .
  - By default, the Docker daemon runs as the root user. This means it has elevated privileges on the system, which is necessary for managing containers and the network interfaces they use. However, this also presents a security risk, as any vulnerabilities in the Docker daemon could be exploited to gain root access to the host system.
- What could be an advantage of running a honeypot inside a virtual machine compared to running it inside a container?
  - Greater Isolation: Virtual machines provide full isolation from the host system, as each VM runs its own kernel. This means that even if a honeypot is compromised, the attacker is limited to the resources of the VM and cannot directly access the host system or other VMs. This is not the case with containers, which share the host's kernel and thus have a thinner layer of isolation.
