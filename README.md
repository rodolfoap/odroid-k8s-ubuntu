# Armbian cluster

This is a setup tool used to run a small Armbian cluster

## Setup

1. Setup the SD card with Armbian/Buster. Download armbian and use the `burn` script
2. Setup Armbian/Buster: run the `setconfig` script
3. Boot. Find the DHCP lease and connect via ssh. Armbian default root password is one, two, three, four. The first connection will force to modify it.
4. Follow the instructions attentively. Do not modify locale/language.
5. Move the /tmp/interfaces file to /etc/network/interfaces. Set the missing parameters.
6. Run the following commands to disable NetworkManager:
```
rm -v /etc/systemd/system/dbus-org.freedesktop.nm-dispatcher.service
rm -v /etc/systemd/system/multi-user.target.wants/NetworkManager.service
```
7. Reboot.
