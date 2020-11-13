# Armbian cluster

This is a setup tool used to run a small Armbian cluster

## Setup

* Setup the SD card with Armbian/Buster. Download armbian and use the `burn` script
* Setup Armbian/Buster: run the `setconfig` script
* Boot. Find the DHCP lease and connect via ssh. Armbian default root password is one, two, three, four. The first connection will force to modify it.
* Change the password!
* Follow the instructions attentively. Do not modify locale/language.
* Move the /tmp/interfaces file to /etc/network/interfaces. Set the missing parameters.
* Run the following commands to disable NetworkManager:
```
rm -v /etc/systemd/system/dbus-org.freedesktop.nm-dispatcher.service
rm -v /etc/systemd/system/multi-user.target.wants/NetworkManager.service
```
* Reboot.
* Modify the hostname: `vi -o /etc/hosts /etc/hostname`
