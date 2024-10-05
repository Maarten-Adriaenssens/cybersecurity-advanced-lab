# Cybersecurity-advanced-lab-template

This environment is used to build up the lab set-up. It provides the base network and hosts. The entire network is built up in VirtualBox, using Vagrant and Ansible.

## Network design

The network consists of 4 subnets:

-   172.30.0.0/16: **internal company LAN**.
-   192.168.62.254/24: **fake internet**.
-   172.10.10.0/24: **employee home LAN**.
-   10.0.2.0/24: **VirtualBox NAT network**.

<!--
```puml
@startuml
nwdiag {
    network internal_company_lan {
        address = 172.30.0.0/16;

        companyrouter [address = "172.30.255.254"];
        dns [address = "172.30.0.4"];
        web [address = "172.30.0.10"];
        database [address = "172.30.0.15"];
        employee [address = "172.30.0.123"];
    }

    network fake_internet {
        address = "192.168.62.0/24";

        companyrouter [address = "192.168.62.253"];
        isprouter [address = "192.168.62.254"];
        your_laptop [address = "dhcp"];
        homerouter [address = "192.168.62.42"];
    }

    network employee_home_lan {
        address = "172.10.0.0/24";

        homerouter [address = "172.10.10.254"];
        remote_employee [address = "172.10.10.123"];
    }

    network virtualbox_nat {
        address = "10.0.2.0/24";

        isprouter [address = "10.0.2.15"];
        virtualbox_nat_gateway [address = "10.0.2.2"];
        virtualbox_nat_dns [address = "10.0.2.3"];
    }

    real_internet [ shape = cloud];
    virtualbox_nat_gateway -- real_internet;
}
@enduml
```
-->

![](https://www.plantuml.com/plantuml/svg/VPBXRi8W4CU_zob8lzjPj6wBMU9xc8MSSjD62WJekcRntOUPeXWAsc-__t7yxZRMWN5z9mevy1OEvBSW_aXqWp8dqag7He9WUzLfa2CJ8A_8vG3d1gqb7wH-fTLYNldVIxrQ5u6uvepgVI6olGVAQu8sZV-MvUSwPBYqAN9UHTI0kpHLpwDYu6075YVOvf75JWiruXHB5pVuN4IMlk24x5yLkgIUidwdLRrwgrRK6wBBCgCe6QBDuh7Jrkei_wnqLBrX0hHJEahmuru_SaVLORxmagOb17diKYEv9q5dxNK63Rch0-__pqyos2c7x7PjCfGRsdThN0zYftwOXAcfNHeD4ylQ3t2yKl4jx00E1nXJEPg9SMbJaUUd6GHntyCjiKVGwFczK3ttQAQXsInEhujpiK79-qxy0G00)

## Usage

1. Create the following host-only network in VirtualBox to simulate the the fake internet:

    - Name: `vboxnet1` (when different, for example on Windows: "VirtualBox Host-Only Ethernet Adapter #2", change this in the [`Vagrantfile`](./Vagrantfile))
    - IP range: 192.168.62.0/24

2. Make sure your vagrant boxes are up to date: `vagrant box update`

3. `vagrant up --parallel` or go slowly (1 by 1) and do `vagrant up <vm_name>`

4. Disable all the NAT connections added by vagrant: `python ./disable-nat.py`

    :warning: `vagrant ssh` won't work anymore and that is **by design**! This command is also not available in a real network, so learn to use SSH properly: login into the required hosts using SSH with IP addresses and jump/forward options!

5. SSH into the isprouter VM:

    ```bash
    ssh vagrant@192.168.62.254
    ```

    :bulb: It could be that you have to wait a minute until the isprouter VM has booted and accepts SSH requests.

    :bulb: Vagrant boxes often use the following credentials:

    - username: `vagrant`
    - password: `vagrant`

6. Execute the following commands. This can take a while!

    ```bash
    isprouter:~$ cd ansible/
    isprouter:~/ansible$ find . -type f -not -path "./files/web/app.jar" -print0 | xargs -0 dos2unix
    isprouter:~/ansible$ chmod u+x run-on-isprouter.sh
    isprouter:~/ansible$ sudo ./run-on-isprouter.sh
    ...

    # Use the following command to check if the network is setup OK
    isprouter:~/ansible$ sudo ansible-playbook --inventory inventory.yml check.yml
    ```

    :bulb: We have added `dos2unix` here for Windows users, but why do they need this? Tip: Linux users don't need this. Tip2: `\r\n` vs. `\n`.

:bulb: The new version of VirtualBox is currently not compatible with vagrant. or you stay on 7.0, or you can use [libvirt](https://vagrant-libvirt.github.io/vagrant-libvirt/) (tip provided by [@CharanChander](https://github.com/CharanChander))
