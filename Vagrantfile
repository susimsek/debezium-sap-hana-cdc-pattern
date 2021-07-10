$script = <<-SCRIPT

# echo "Preparing local node_modules folder…"
# mkdir -p /home/vagrant/app/sdk/vagrant_node_modules
# chown vagrant:vagrant /home/vagrant/app/sdk/vagrant_node_modules

echo "cd $1" >> /home/vagrant/.profile
echo "cd $1" >> /home/vagrant/.bashrc
echo "All good!!"
SCRIPT


VAGRANTFILE_API_VERSION = "2"
VM_SYNCED_FOLDER_PATH = "/vagrant/go/src/app"

# Vagrant base box to use
BOX_BASE = "ubuntu/bionic64"

# set servers list and their parameters
	NODES = [
  	# { :hostname => "haproxy", :ip => "192.168.12.10", :cpus => 1, :mem => 512, :type => "haproxy" },
  	{ :hostname => "k8smaster", :ip => "192.168.12.11", :cpus => 4, :mem => 10240, :type => "k8s" }
  	# { :hostname => "k8snode1", :ip => "192.168.12.12", :cpus => 2, :mem => 2048, :type => "k8s" }
	]

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    # 1. Use this for "Standard setup"
    etcHosts = ""

    config.vm.box = BOX_BASE
    config.vm.synced_folder ".", VM_SYNCED_FOLDER_PATH
    # Uncomment the lines below if you would like to protect the VM
    # config.ssh.username = 'vagrant'
    # config.ssh.password = 'vagrant'
    # config.ssh.insert_key = 'true'

    NODES.each do |node|
        if node[:type] != "haproxy"
        	etcHosts += "echo '" + node[:ip] + "   " + node[:hostname] + "' >> /etc/hosts" + "\n"
    		else
    			etcHosts += "echo '" + node[:ip] + "   " + node[:hostname] + " elb.kub ' >> /etc/hosts" + "\n"
    	end
    end #end NODES

    NODES.each do |node|
        config.vm.define node[:hostname] do |cfg|
            cfg.vm.hostname = node[:hostname]
            cfg.vm.network "private_network", ip: node[:ip]
            cfg.vm.provider :virtualbox do |vb|
                vb.customize [ "modifyvm", :id, "--cpus", node[:cpus] ]
                vb.customize [ "modifyvm", :id, "--memory", node[:mem] ]
                vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
                vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
                vb.customize ["modifyvm", :id, "--name", node[:hostname] ]
                vb.gui = false
            end #end provider
            cfg.vm.provider :hyperv do |hv|
                hv.customize [ "modifyvm", :id, "--cpus", node[:cpus] ]
                hv.customize [ "modifyvm", :id, "--memory", node[:mem] ]
                hv.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
                hv.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
                hv.customize ["modifyvm", :id, "--name", node[:hostname] ]
                hv.gui = false
            end #end provider

            cfg.vm.provision :shell, inline: $script, args: "#{VM_SYNCED_FOLDER_PATH}"
            cfg.vm.provision :shell, :inline => etcHosts
        end
    end
end