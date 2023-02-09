# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.ssh.insert_key = false

  config.vm.define "containers" do |containers|
    containers.vm.box = "shekeriev/debian-11"
    containers.vm.hostname = "containers.exam"
    containers.vm.network "private_network", ip: "192.168.121.121"

    $terraform = <<TERRAFORM
echo '# Install Terraform'
wget https://releases.hashicorp.com/terraform/1.3.7/terraform_1.3.7_linux_amd64.zip -O /tmp/terraform.zip
unzip /tmp/terraform.zip
sudo mv terraform /usr/local/bin
rm /tmp/terraform.zip
TERRAFORM
  
    $python = <<EOS
echo "* Install Python3 ..." 
sudo apt-get update
sudo apt-get install -y python3 python3-pip python3-distro
EOS

    containers.vm.provider "virtualbox" do |v|
      v.gui = false
      v.memory = 4096
      v.cpus = 1
    end
    containers.vm.provision "shell", inline: $terraform, privileged: false
    containers.vm.provision "shell", inline: $python, privileged: false

    containers.vm.synced_folder "terraform-containers/configs/salt/", "/srv/salt"
    containers.vm.provision :salt do |sa|
        sa.bootstrap_options = "-D -R repo.saltproject.io/salt -X"
        sa.masterless = true
        sa.minion_config = "terraform-containers/minionfiles/minion.yml"
        sa.run_highstate = true
        sa.verbose = true
    end
  end

  config.vm.define "web" do |web|
    web.vm.box = "shekeriev/debian-11"
    web.vm.hostname = "web.exam"
    web.vm.network "private_network", ip: "192.168.121.122"

    $puppetdeb = <<PUPPETDEB
    wget https://apt.puppet.com/puppet7-release-bullseye.deb
    sudo dpkg -i puppet7-release-bullseye.deb
    sudo apt-get update
    sudo apt-get install -y puppet-agent
PUPPETDEB

    $modulegit = <<MODULEGIT
    puppet module install puppetlabs-vcsrepo
    sudo cp -vR ~/.puppetlabs/etc/code/modules/ /etc/puppetlabs/code/
MODULEGIT

    web.vm.provider "virtualbox" do |v|
      v.gui = false
      v.memory = 4096
      v.cpus = 1
    end
    web.vm.provision "shell", path: "add-hosts.sh"
    web.vm.provision "shell", inline: $puppetdeb, privileged: false
    web.vm.provision "shell", inline: $modulegit, privileged: false

    web.vm.provision "puppet" do |puppet|
      puppet.manifests_path = "terraform-web/manifests"
      puppet.manifest_file = "web.pp"
      puppet.options = "--verbose --debug"
    end

  end

  config.vm.define "db" do |db|
    db.vm.box = "shekeriev/debian-11"
    db.vm.hostname = "db.exam"
    db.vm.network "private_network", ip: "192.168.121.123"

    $puppetdeb = <<PUPPETDEB
    wget https://apt.puppet.com/puppet7-release-bullseye.deb
    sudo dpkg -i puppet7-release-bullseye.deb
    sudo apt-get update
    sudo apt-get install -y puppet-agent
PUPPETDEB

    $puppetmods = <<PUPPETMODS
    puppet module install puppetlabs-vcsrepo
    puppet module install puppetlabs/mysql
    sudo cp -vR ~/.puppetlabs/etc/code/modules/ /etc/puppetlabs/code/
PUPPETMODS

    db.vm.provider "virtualbox" do |v|
      v.gui = false
      v.memory = 4096
      v.cpus = 1
    end

    db.vm.provision "shell", path: "add-hosts.sh"
    db.vm.provision "shell", inline: $puppetdeb, privileged: false
    db.vm.provision "shell", inline: $puppetmods, privileged: false

    db.vm.provision "puppet" do |puppet|
      puppet.manifests_path = "terraform-db/manifests"
      puppet.manifest_file = "db.pp"
      puppet.options = "--verbose --debug"
    end
  end
  
end
