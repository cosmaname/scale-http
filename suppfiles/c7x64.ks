install
url --url=http://mirror.karneval.cz/pub/centos/7/os/x86_64/
autostep
reboot
skipx
text
lang en_US.UTF-8
timezone --utc Europe/Prague
selinux --disabled
firewall --disabled
zerombr
clearpart --initlabel --drives=sda --all
bootloader --location=mbr --append="text net.ifnames=0 biosdevname=0"
part swap --size=1024
part / --fstype=ext4 --size=2048 --grow
rootpw --iscrypted $1$wNTPft45$qFS0nSMYCNpMQkWQOnYWW1
network --device eth0 --bootproto dhcp --noipv6 --nodefroute
network --device eth1 --bootproto dhcp --noipv6
repo --name=base --baseurl=http://mirror.karneval.cz/pub/centos/7/os/x86_64/
repo --name=updates --baseurl=http://mirror.karneval.cz/pub/centos/7/updates/x86_64/
repo --name=epel --baseurl=http://mirror.karneval.cz/pub/fedora/epel/7/x86_64/

%packages --nobase --excludedocs --instLangs=en
@core
salt-minion
%end

services --enabled=salt-minion

%post
#!/bin/bash
cat <<SALT >/etc/salt/minion
master: 192.168.252.200
mine_functions:
 network.ip_addrs: ['eth0']
SALT
%end
