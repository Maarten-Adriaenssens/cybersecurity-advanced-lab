
#HOST_ONLY_NETWORK = "vboxnet1" # Typically on Linux/Mac
HOST_ONLY_NETWORK = "VirtualBox Host-Only Ethernet Adapter #2" # Typically on Windows

Vagrant.configure("2") do |config|
    config.vm.define "companyrouter" do |host|
        host.vm.box = "almalinux/9"
        host.vm.hostname = "companyrouter"

        host.vm.network "private_network", ip: "192.168.62.253", netmask: "255.255.255.0", name: HOST_ONLY_NETWORK
        host.vm.network "private_network", ip: "172.30.255.254", netmask: "255.255.0.0", virtualbox__intnet: "internal-company-lan"

        host.vm.provider :virtualbox do |v|
            v.customize ["modifyvm", :id, "--groups", "/CSA"]
            v.name = "companyrouter"
            v.cpus = "1"
            v.memory = "6334"
        end

        host.vm.provision "shell", inline: <<-SHELL
            # Default gateway
            nmcli connection modify "System eth1" ipv4.gateway 192.168.62.254
            systemctl restart NetworkManager
        SHELL
    end

    config.vm.define "dns" do |host|
        host.vm.box = "generic/alpine318"
        host.vm.hostname = "dns"

        host.vm.network "private_network", ip: "172.30.0.4", netmask: "255.255.255.0", virtualbox__intnet: "internal-company-lan"

        host.vm.provider :virtualbox do |v|
            v.customize ["modifyvm", :id, "--groups", "/CSA"]
            v.name = "dns"
            v.cpus = "1"
            v.memory = "256"
        end

        host.vm.provision "shell", inline: <<-SHELL
            # For ansible
            apk --no-cache add python3

            # Default gateway
            echo "gateway 172.30.255.254" >> /etc/network/interfaces
            service networking restart
        SHELL
    end

    config.vm.define "web" do |host|
        host.vm.box = "almalinux/9"
        host.vm.hostname = "web"

        host.vm.network "private_network", ip: "172.30.0.10", netmask: "255.255.255.0", virtualbox__intnet: "internal-company-lan"

        host.vm.provider :virtualbox do |v|
            v.customize ["modifyvm", :id, "--groups", "/CSA"]
            v.name = "web"
            v.cpus = "1"
            v.memory = "1024"
        end

        host.vm.provision "shell", inline: <<-SHELL
            # Default gateway
            nmcli connection modify "System eth1" ipv4.gateway 172.30.255.254
            systemctl restart NetworkManager
        SHELL
    end

    config.vm.define "database" do |host|
        host.vm.box = "generic/alpine318"
        host.vm.hostname = "database"

        host.vm.network "private_network", ip: "172.30.0.15", netmask: "255.255.255.0", virtualbox__intnet: "internal-company-lan"

        host.vm.provider :virtualbox do |v|
            v.customize ["modifyvm", :id, "--groups", "/CSA"]
            v.name = "database"
            v.cpus = "1"
            v.memory = "256"
        end

        host.vm.provision "shell", inline: <<-SHELL
            # For ansible
            apk --no-cache add python3

            # Default gateway
            echo "gateway 172.30.255.254" >> /etc/network/interfaces
            service networking restart
        SHELL
    end

    config.vm.define "employee" do |host|
        host.vm.box = "generic/alpine318"
        host.vm.hostname = "employee"

        # TODO DHCP
        host.vm.network "private_network", ip: "172.30.0.123", netmask: "255.255.255.0", virtualbox__intnet: "internal-company-lan"

        host.vm.provider :virtualbox do |v|
            v.customize ["modifyvm", :id, "--groups", "/CSA"]
            v.name = "employee"
            v.cpus = "1"
            v.memory = "256"
        end

        host.vm.provision "shell", inline: <<-SHELL
            # For ansible
            apk --no-cache add python3

            # Default gateway
            echo "gateway 172.30.255.254" >> /etc/network/interfaces
            service networking restart
        SHELL
    end

    config.vm.define "isprouter" do |host|
        host.vm.box = "generic/alpine318"
        host.vm.hostname = "isprouter"

        host.vm.network "private_network", ip: "192.168.62.254", netmask: "255.255.255.0", name: HOST_ONLY_NETWORK

        host.vm.provider :virtualbox do |v|
            v.customize ["modifyvm", :id, "--groups", "/CSA"]
            v.name = "isprouter"
            v.cpus = "1"
            v.memory = "256"
        end

        host.vm.provision "shell", inline: <<-SHELL
            apk --no-cache add python3 # For ansible
        SHELL
        host.vm.provision "file", source: "ansible", destination: "$HOME/ansible"
    end

    config.vm.define "homerouter" do |host|
        host.vm.box = "almalinux/9"
        host.vm.hostname = "homerouter"

        host.vm.network "private_network", ip: "192.168.62.42", netmask: "255.255.255.0", name: HOST_ONLY_NETWORK
        host.vm.network "private_network", ip: "172.10.10.254", netmask: "255.255.255.0", virtualbox__intnet: "employee-home-lan"

        host.vm.provider :virtualbox do |v|
            v.customize ["modifyvm", :id, "--groups", "/CSA"]
            v.name = "homerouter"
            v.cpus = "1"
            v.memory = "1024"
        end

        host.vm.provision "shell", inline: <<-SHELL
            # Default gateway
            nmcli connection modify "System eth1" ipv4.gateway 192.168.62.254
            systemctl restart NetworkManager
        SHELL
    end

    config.vm.define "remote-employee" do |host|
        host.vm.box = "almalinux/9"
        host.vm.hostname = "remote-employee"

        host.vm.network "private_network", ip: "172.10.10.123", netmask: "255.255.255.0", virtualbox__intnet: "employee-home-lan"

        host.vm.provider :virtualbox do |v|
            v.customize ["modifyvm", :id, "--groups", "/CSA"]
            v.name = "remote-employee"
            v.cpus = "1"
            v.memory = "1024"
        end

        host.vm.provision "shell", inline: <<-SHELL
            # Default gateway
            nmcli connection modify "System eth1" ipv4.gateway 172.10.10.254
            systemctl restart NetworkManager
        SHELL
    end

    config.vm.define "wazuh" do |host|
        host.vm.box = "almalinux/9"
        host.vm.hostname = "wazuh"

        host.vm.network "private_network", ip: "172.30.0.20", netmask: "255.255.255.0", virtualbox__intnet: "internal-company-lan"

        host.vm.provider :virtualbox do |v|
            v.customize ["modifyvm", :id, "--groups", "/CSA"]
            v.name = "wazuh"
            v.cpus = "2"
            v.memory = "6334"
        end

        host.vm.provision "shell", inline: <<-SHELL
            # Update system
            yum update -y
            # Install dependencies
            yum install -y curl unzip wget
            # Download and install Wazuh repository
            rpm --import https://packages.wazuh.com/key/GPG-KEY-WAZUH
            echo -e '[wazuh]\ngpgcheck=1\ngpgkey=https://packages.wazuh.com/key/GPG-KEYWAZUH\nenabled=1\nname=EL-$releasever -Wazuh\nbaseurl=https://packages.wazuh.com/4.x/yum/\nprotect=1' | tee /etc/yum.repos.d/wazuh.repo

            # Install Wazuh manager
            yum install -y wazuh-manager
            # Start and enable Wazuh
            systemctl enable wazuh-manager
            systemctl start wazuh-manager
            # Configure default gateway
            nmcli connection modify "System eth1" ipv4.gateway 172.30.255.254
            systemctl restart NetworkManager
        SHELL
    end
end
