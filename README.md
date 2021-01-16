# OdroidMC1/Kubernetes/Ubuntu cluster

The Odroid-MC1: https://www.hardkernel.com/shop/odroid-mc1-my-cluster-one-with-32-cpu-cores-and-8gb-dram/

![OcroidMC1](https://github.com/rodolfoap/odroid-k8s-armbian/blob/master/mc1.jpg)

This is a setup reference to install and run a small Odroid-MC1+Armbian+Kubernetes cluster.

## Odroid setup

* Download Ubuntu on this directory.
```
wget https://odroid.in/ubuntu_20.04lts/XU3_XU4_MC1_HC1_HC2/ubuntu-20.04.1-5.4-minimal-odroid-xu4-20200812.img.xz
wget http://de.eu.odroid.in/ubuntu_20.04lts/XU3_XU4_MC1_HC1_HC2/ubuntu-20.04-5.4-minimal-odroid-xu4-20210112.img.xz
```

* Put an SD card to some slot. Find the device it is referred on (e.g. `/dev/sdc1`).
* `./burn` will setup the SD card with Ubuntu/Focal
* `./save` will save install data to the card. Normally, private data. If you don't have access to the `/dat` directory, just continue, this document shows how to configure the system.
* Insert the SD card on the MC1. Boot. Find the DHCP lease and connect to it via ssh.
* Follow this instructions attentively:
```
$ ssh root@192.168.1.26
...
root@192.168.1.26's password: odroid

useradd -m -s /bin/bash rodolfoap
passwd
passwd rodolfoap

apt update
apt -y install mc lsof rsync
...
```
* Change the password!
* If required, change the locale to en_US.UTF8: `dpkg-reconfigure locales`
* Modify the hostname: `vi -o /etc/hosts /etc/hostname`
* Use a `/etc/netplan` file to define a static IP address:
```
# /etc/netplan/eth0.yaml
network:
  version: 2
  renderer: networkd

  ethernets:
    eth0:
      addresses:
        - 192.168.1.91/24
      gateway4: 192.168.1.254
      nameservers:
        search: [ lan ]
        addresses: [ 192.168.1.254 ]
```

* Add `/etc/docker/daemon.json`:
```
cat << 'EOF' > /etc/docker/daemon.json
{
	"exec-opts": ["native.cgroupdriver=systemd"],
	"log-driver": "json-file",
	"log-opts": {
		"max-size": "100m"
	},
	"storage-driver": "overlay2"
}
EOF
```

* Enable IP forwarding and use classic iptables:
```
update-alternatives --set iptables /usr/sbin/iptables-legacy
sed -i '/net.ipv4.ip_forward/s/#//' /etc/sysctl.conf
```

* Disable IPv6:
```
$ tail /etc/sysctl.conf
...
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
```

* Disable swap (didn't found another way):
```
cat << 'EOF' > /etc/rc.local
#!/bin/sh

/usr/sbin/swapoff -a
exit 0
EOF

```

* Update distro:
```
apt full-upgrade
```
* Reboot

## Kubernetes

* https://wiki.learnlinux.tv/index.php/How_to_build_your_own_Raspberry_Pi_Kubernetes_Cluster
* https://www.youtube.com/watch?v=B2wAJ5FLOYw

```
swapoff -a # Just in case, check /proc/swaps being empty

curl -sL get.docker.com|sh
usermod -aG docker rodolfoap

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubeadm kubectl kubectx # Master
apt-get install -y kubeadm kubelet         # Workers
```

* You can check _cgroups_ validity:
```
wget https://raw.githubusercontent.com/docker/docker/master/contrib/check-config.sh -O cgroups_check && chmod +x cgroups_check
./cgroups_check
```

## Master Node

```
kubeadm config images pull

# In case of requiring a different CIDR,
#kubeadm init --apiserver-advertise-address=0.0.0.0 --pod-network-cidr 10.10.0.0/16 --service-cidr 10.11.0.0/16

# Or the common one, ready for Flannel to run,
kubeadm init --apiserver-advertise-address=0.0.0.0 --pod-network-cidr=10.244.0.0/16 # Common one
```

Which will output something like...

```
	Your Kubernetes control-plane has initialized successfully!

	To start using your cluster, you need to run the following as a regular user:

		mkdir -p $HOME/.kube
		sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
		sudo chown $(id -u):$(id -g) $HOME/.kube/config

	You should now deploy a pod network to the cluster.
	Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
		https://kubernetes.io/docs/concepts/cluster-administration/addons/

	Then you can join any number of worker nodes by running the following on each as root:

	kubeadm join 192.168.1.91:6443 --token o255i5.bian2b1m6hcd3yvn --discovery-token-ca-cert-hash sha256:134e4bef7cee2b5548e5ceb04bbf3c5a0a7ca3b7dda66f9e14588a685141edbc
```

* **Save** the last output on the MASTER node, in the file `/root/kubejoin`.
* Verify that the last output was **saved** on the MASTER node, in the file `/root/kubejoin`!!!
* Verify that `/var/lib/kubelet/config.yaml` includes:
```
...
cgroupDriver: systemd
failSwapOn: false

```

* As a regular user:

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=$HOME/.kube/config
echo "export KUBECONFIG=$HOME/.kube/config" | tee -a ~/.bashrc

# Required to have a proper flannel configuration, when using the 10.10.0.0/16 network
# Or, in case of a different CIDR...
# curl -s https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml|sed 's/10\.244\.0\.0/10.10.0.0/' > kube-flannel.yml
wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f kube-flannel.yml

kubectl get nodes,all,pv,pvc,ep
kubectl get pods --all-namespaces
sudo journalctl -u service-name.service
```

### Make the master a worker

```
kubectl taint nodes --all node-role.kubernetes.io/master-
```

## Worker Nodes

* On each node, as root, run the `kubeadm join` command saved in the MASTER node, in the file `/root/kubejoin`.

```
kubeadm join 192.168.1.91:6443 --token o255i5.bian2b1m6hcd3yvn --discovery-token-ca-cert-hash sha256:134e4bef7cee2b5548e5ceb04bbf3c5a0a7ca3b7dda66f9e14588a685141edbc
```
**The installation has finished.**

## Some personal helpers...

```
for a in mc{1..4}; do ssh.$a apt install -y mc & done

# Example single files
for a in mc{1..4}; do scp root/.bashrc $a:/root/; done

# Example complete directories
for a in mc{1..4}; do scp -pr home/.docker/ $a:/home/docker/.docker/; done
...
```
## Tmux Broadcast application

* Just launch the app:
```
./ssh.all
```

Shortcuts:

* `F5` activate broadcast
* `F6` deactivate broadcast
* `F7` switch to the previous pane
* `F8` switch to the next pane

## Bad reinstalls

* It is difficult to pin the precise error, but after reinstalling `Kubernetes` multiple times, a weird behavior occurred (https://superuser.com/questions/1613126/).

Apparently the solution was to:

	* [DISCARDED] Include `--apiserver-advertise-address=0.0.0.0` in `kubeadm init`;
	* [DISCARDED] include `cgroupDriver: systemd` in `/var/lib/kubelet/config.yaml` before installing Flannel;
	* [DISCARDED] include `failSwapOn: false` in `/var/lib/kubelet/config.yaml` before installing Flannel.
	* Delete the configuration "--port=0" in `/etc/kubernetes/manifests/controller-manager.conf` and `/etc/kubernetes/manifests/scheduler.conf` (verifiable with `kc get cs`).
