# Armbian cluster

This is a setup tool used to run a small Armbian cluster

## Setup

1. Setup Armbian/Buster
```
dmesg
xz -d < Armbian_20.08.1_Odroidxu4_buster_legacy_4.14.195.img.xz - | dd of=/dev/sdc bs=4096
mount /dev/sdc1 /mnt
vi etc/NetworkManager/system-connections/Wired\ connection\ 1.nmconnection # Fix the IP address
cp etc/NetworkManager/system-connections/Wired\ connection\ 1.nmconnection /mnt/etc/NetworkManager/system-connections/
umount /mnt
reboot
```

2. Boot

* Armbian default root password is one, two, three, four. The first connection will force to modify it.
* 
