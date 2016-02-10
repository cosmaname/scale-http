Scaling HTTP with Keepalived / Conntrack / Nginx
=======

## Purpose ##
Ensure availability of a simple web app in automated fashion and completely transparent to the end user.
Toolkit employed:

 1. Any hardware or virtualization product capable of running a recent Linux distro
 2. CentOS 7 x64 + EPEL for base OS
 3. SaltStack for configuration management (http://saltstack.com/community/)
 4. Keepalived for floating IP (http://keepalived.org/)
 5. Conntrackd for TCP connection persistence (http://conntrack-tools.netfilter.org/)
 6. Nginx for HTTP-level load balancing and health checks (https://www.nginx.com/resources/wiki/)
 7. A simple Go app that services HTTP requests
![network diagram](https://raw.githubusercontent.com/rgcosma/shst/master/suppfiles/nginx%20lb.png)

## Infrastructure deployment ##
Setup assumes a VMware environment (vCenter required for VM cloning), a CentOS management instance and each VM will have two interfaces - one internal and one with access to the public 'Net to download packages.

![hypervisor config](https://raw.githubusercontent.com/rgcosma/shst/master/suppfiles/nginx%20esxi.png)

 1. Configure a management workstation/VM with any recent Linux version, enable DHCP and TFTP on the internal interface. A minimal dnsmasq.conf is available in the suppfiles folder, the other files listed in pxelinux.tree are available in the syslinux package and in the os/images/pxeboot folder of any CentOS mirror.
 2. Create a minimal VM template of CentOS, with only the Salt Minion service running. A ![sample kickstart file](https://raw.githubusercontent.com/rgcosma/shst/master/suppfiles/c7x64.ks) for this is also available. It generates a ~1GB OS image. No other services or users are needed (the root login is enabled for testing purposes, but can be safely disabled).
 3. VMs will be deployed using salt-cloud (part of SaltStack). Configuration for an entire application can be defined in a couple YAML files, and should be easy to adapt to any of the other cloud providers supported(EC2, Azure, OpenStack, ...)
  1. In /etc/salt/cloud.providers.d, define the address and credentials for vCenter server (see lab-vmware.conf)
  2. In /etc/salt/cloud.profiles.d, define all the common parameters for the new VMs to be deployed (updatehostname.sls is just a quick 'hack' to also set the system hostname, optional. SLS files are stored by default under /srv/salt)
 4. Deploy the environment using smth like ```sudo salt-cloud -p c7lab kdct1 kdct2 nginx1 nginx2 go1 go2```
   Expected outcome: 6 VMs deployed, each with the hostname set to the string specified in the command line, and pending authentication requests on the master:
```bash
$ sudo salt-key -L
Accepted Keys:
Denied Keys:
Unaccepted Keys:
go1
kdct1
nginx1
Rejected Keys:
```
No data is exchanged between master and minions until the keys are accepted (important privacy feature), also the IP address(es) of the minions don't have to be known/static (important in a cloud deployment): all the configuration is linked to the ID declared in the SSL cert subject, and minions pull (ZMQ) from the master, so do not need any port open.

## Configuration management ##
Installed packages, service status and configuration is defined in SLS (YAML format) files, published by the master and applied by the minions either locally scheduled on the nodes or forces via a ```salt '*' state.highstate```
Starting from /srv/salt/top.sls, configuration items can be defined globally, for a class or single system. Sample output for the configuration defined in common.sls:
```
Summary
------------
Succeeded: 3
Failed:    0
------------
Total states run:     3
nginx1:
.
.
.
          ID: ntpd
    Function: service.running
      Result: True
     Comment: Service ntpd is already enabled, and is in the desired state
     Started: 16:42:47.765441
    Duration: 203.227 ms
     Changes:
----------
          ID: sysctl_conf
    Function: file.managed
        Name: /etc/sysctl.d/90-custom.conf
      Result: True
     Comment: File /etc/sysctl.d/90-custom.conf is in the correct state
     Started: 22:47:25.014762
    Duration: 3.335 ms
     Changes:
```
At this point, the minions need to be able to communicate their management IP addresses to create groups, this is where the line
```
mine_functions:
 network.ip_addrs: ['eth0']
```
specified in the kickstart file is used
 
 1. Keepalived (see keepalive.sls): a single static IP floats across several nodes, election done via VRRP. Connections to the backend are NATed.
 2. Conntrackd (see conntrack.sls): avoids TCP resets by copying the kernel connections table, synchronization in case of failure / role change done by a simple shell script (see notify.sh).
 3. Nginx (see nginx.sls): load balancing at L7, also allows for more complex health checks.
 4. Web app (see webapp.sls): stateless Go app, simply answers HTTP requests with the node hostname.

## Security & manageability benefits ##
 1. Only a minimal OS image is deployed, largely hypervisor-independent.
 2. No services beyond the actual desired app are needed, no additional listening ports, no logins allowed (not even root).
 3. A single entry point (IP,port) is visible for external users.
 4. A single basic Linux installation can deploy and monitor all the nodes.
 5. Scaling out is just a matter of 'salt-cloud -p' then 'salt state.highstate'.
