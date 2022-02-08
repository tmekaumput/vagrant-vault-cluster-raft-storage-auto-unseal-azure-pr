# -*- mode: ruby -*-
# vi: set ft=ruby :

GID=1001
UID=1001

shared_dir="/var/shared"
primary_shared_dir="#{shared_dir}/primary"
secondary_shared_dir="#{shared_dir}/secondary"
client_id=ENV['CLIENT_ID']
client_secret=ENV['CLIENT_SECRET']
tenant_id=ENV['TENANT_ID']
vault_name=ENV['VAULT_NAME']
key_name=ENV['KEY_NAME']

prim_leader_node = {
  :id => "prim_leader_node",
  :ip => "192.168.56.190",
  :hostname => "prim-vault-leader",
  :api_addr => "http://192.168.56.190:8200"
}

prim_followers = [
  {
    :id => "prim_follower_node1",
    :ip => "192.168.56.191",
    :hostname => "prim-vault-follower1",
    :ui_port => 8202
  },
  {
    :id => "prim_follower_node2",
    :ip => "192.168.56.192",
    :hostname => "prim-vault-follower2",
    :ui_port => 8204
  }
]

sec_leader_node = {
  :id => "sec_leader_node",
  :ip => "192.168.56.200",
  :hostname => "sec-vault-leader",
  :api_addr => "http://192.168.56.200:8200"
}

sec_followers = [
  {
    :id => "follower_node1",
    :ip => "192.168.56.201",
    :hostname => "sec-vault-follower1",
    :ui_port => 9202
  },
  {
    :id => "follower_node2",
    :ip => "192.168.56.202",
    :hostname => "sec-vault-follower2",
    :ui_port => 9204
  }
]

Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
    vb.customize ["modifyvm", :id, "--cpus", "1"]
    vb.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
    vb.customize ["modifyvm", :id, "--chipset", "ich9"]
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
  end

  config.vm.define "prim_vault_leader" do |vault_leader|
    vault_leader.vm.box = "bento/centos-7.9"
    vault_leader.vm.box_version = "202110.25.0"
    vault_leader.vm.hostname = prim_leader_node[:hostname]
    vault_leader.vm.network "private_network", ip: prim_leader_node[:ip]
    vault_leader.vm.network "forwarded_port", guest: 8200, host: 9200, auto_correct: true
    vault_leader.vm.provision "shell", path: "scripts/setup-user.sh", args: ["vault", UID, GID]
    vault_leader.vm.synced_folder "data/", shared_dir, owner: "vault",  group: "vault", :mount_options => ["uid=#{UID},gid=#{GID},dmode=744,fmode=744"]
    vault_leader.vm.provision "file", source: "./license.txt", destination: "/tmp/license.txt"
    vault_leader.vm.provision "shell", path: "scripts/common.sh"
    vault_leader.vm.provision "shell", path: "scripts/install-vault.sh", args: prim_leader_node[:ip]
    vault_leader.vm.provision "shell", path: "scripts/create-systemd-unit.sh"
    vault_leader.vm.provision "shell", path: "scripts/create-configs.sh", args: [prim_leader_node[:id], prim_leader_node[:ip], key_name, prim_leader_node[:id], prim_leader_node[:api_addr], client_id, client_secret, tenant_id, vault_name, primary_shared_dir] 

    vault_leader.vm.provision "shell", inline: "sudo systemctl enable vault.service"
    vault_leader.vm.provision "shell", inline: "sudo systemctl start vault"
    vault_leader.vm.provision "shell", path: "scripts/setup-leader-node.sh", args: primary_shared_dir
    vault_leader.vm.provision "shell", path: "scripts/setup-primary.sh", args: primary_shared_dir
  end

  prim_followers.each do |follower|
    config.vm.define follower[:id] do |follower_node|
      follower_node.vm.box = "bento/centos-7.9"
      follower_node.vm.box_version = "202110.25.0"
      follower_node.vm.hostname = follower[:hostname]
      follower_node.vm.network "private_network", ip: follower[:ip]
      follower_node.vm.network "forwarded_port", guest: 8200, host: follower[:ui_port], auto_correct: true
      follower_node.vm.provision "shell", path: "scripts/setup-user.sh", args: ["vault", UID, GID]
      follower_node.vm.synced_folder "data/", shared_dir, owner: "vault",  group: "vault", :mount_options => ["uid=#{UID},gid=#{GID},dmode=744,fmode=744"]
      follower_node.vm.provision "file", source: "./license.txt", destination: "/tmp/license.txt"
      follower_node.vm.provision "shell", path: "scripts/common.sh"
      follower_node.vm.provision "shell", path: "scripts/install-vault.sh", args: follower[:ip]
      follower_node.vm.provision "shell", path: "scripts/create-systemd-unit.sh"
      follower_node.vm.provision "shell", path: "scripts/create-configs.sh", args: [follower[:id], follower[:ip], key_name, prim_leader_node[:id], prim_leader_node[:api_addr], client_id, client_secret, tenant_id, vault_name, primary_shared_dir]
      follower_node.vm.provision "shell", inline: "sudo systemctl enable vault.service"
      follower_node.vm.provision "shell", inline: "sudo systemctl start vault"
    end
  end

  config.vm.define "sec_vault_leader" do |vault_leader|
    vault_leader.vm.box = "bento/centos-7.9"
    vault_leader.vm.box_version = "202110.25.0"
    vault_leader.vm.hostname = sec_leader_node[:hostname]
    vault_leader.vm.network "private_network", ip: sec_leader_node[:ip]
    vault_leader.vm.network "forwarded_port", guest: 8200, host: 10200, auto_correct: true
    vault_leader.vm.provision "shell", path: "scripts/setup-user.sh", args: ["vault", UID, GID]
    vault_leader.vm.synced_folder "data/", shared_dir, owner: "vault",  group: "vault", :mount_options => ["uid=#{UID},gid=#{GID},dmode=744,fmode=744"]
    vault_leader.vm.provision "file", source: "./license.txt", destination: "/tmp/license.txt"
    vault_leader.vm.provision "shell", path: "scripts/common.sh"
    vault_leader.vm.provision "shell", path: "scripts/install-vault.sh", args: sec_leader_node[:ip]
    vault_leader.vm.provision "shell", path: "scripts/create-systemd-unit.sh"
    vault_leader.vm.provision "shell", path: "scripts/create-configs.sh", args: [sec_leader_node[:id], sec_leader_node[:ip], key_name, sec_leader_node[:id], sec_leader_node[:api_addr], client_id, client_secret, tenant_id, vault_name, secondary_shared_dir]

    vault_leader.vm.provision "shell", inline: "sudo systemctl enable vault.service"
    vault_leader.vm.provision "shell", inline: "sudo systemctl start vault"
    vault_leader.vm.provision "shell", path: "scripts/setup-leader-node.sh", args: secondary_shared_dir
    vault_leader.vm.provision "shell", path: "scripts/setup-secondary.sh", args: secondary_shared_dir
  end

  sec_followers.each do |follower|
    config.vm.define follower[:id] do |follower_node|
      follower_node.vm.box = "bento/centos-7.9"
      follower_node.vm.box_version = "202110.25.0"
      follower_node.vm.hostname = follower[:hostname]
      follower_node.vm.network "private_network", ip: follower[:ip]
      follower_node.vm.network "forwarded_port", guest: 8200, host: follower[:ui_port], auto_correct: true
      follower_node.vm.provision "shell", path: "scripts/setup-user.sh", args: ["vault", UID, GID]
      follower_node.vm.synced_folder "data/", shared_dir, owner: "vault",  group: "vault", :mount_options => ["uid=#{UID},gid=#{GID},dmode=744,fmode=744"]
      follower_node.vm.provision "file", source: "./license.txt", destination: "/tmp/license.txt"
      follower_node.vm.provision "shell", path: "scripts/common.sh"
      follower_node.vm.provision "shell", path: "scripts/install-vault.sh", args: follower[:ip]
      follower_node.vm.provision "shell", path: "scripts/create-systemd-unit.sh"
      follower_node.vm.provision "shell", path: "scripts/create-configs.sh", args: [follower[:id], follower[:ip], key_name, sec_leader_node[:id], sec_leader_node[:api_addr], client_id, client_secret, tenant_id, vault_name, secondary_shared_dir]
      follower_node.vm.provision "shell", inline: "sudo systemctl enable vault.service"
      follower_node.vm.provision "shell", inline: "sudo systemctl start vault"
    end
  end

end
