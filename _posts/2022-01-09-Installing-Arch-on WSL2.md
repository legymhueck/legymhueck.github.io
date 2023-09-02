---
layout: post
title: Arch Linux on WLS2
author: MicLeh
date: 2023-09-02 09:42:00 +0200
pin: true
categories: [Linux, ArchLinux]
tags: [linux]
---

# Installing Arch Linux from bootstrap

## Getting the bootstrap image from official archlinux.org mirrors

Open up a powershell terminal to download the archlinux bootstrap tarball

```powershell
Invoke-WebRequest -Uri "http://ftp.halifax.rwth-aachen.de/archlinux/iso/latest/archlinux-bootstrap-2022.06.01-x86_64.tar.gz" -OutFile "$HOME\Downloads\archlinux-bootstrap.tar.gz"
```

## Repackaging the .tar.gz

Extract and repackage the downloaded bootstrap file in another Linux distro, e.g. WSL Ubuntu

```bash
# Go to the user's Downloads folder
cd /mnt/c/Users/$USER/Downloads/

# Move the downloaded file to the Linux home folder
mv archlinux-bootstrap-x86_64.tar.gz ~

# Go to your home folder
cd

# Extract the tar.gz bootstap file
tar -zxvf archlinux-bootstrap-x86_64.tar.gz

# Go to the following subdirectory
cd root.x86_64

# Repackage the extracted tar.gz (there is a dot at the end)
tar -zcvf archlinux-bootstrap_repackage-x86_64.tar.gz .

# Put the file back to your Windows Downloads folder
mv archlinux-bootstrap_repackage-x86_64.tar.gz /mnt/c/Users/$USER/Downloads/
```

## Pick an installation location

Create a directory in you home folder labeled "wsl". Make sure that each distro has their own location.

```powershell
md "$HOME\wsl\arch"
```

## Importing and System Update

Import the tarball requires an installation location with no other distro, or otherwise it will fail.

```console
wsl --import Arch "$HOME\wsl\arch" "$HOME\Downloads\archlinux-bootstrap_repackage-x86_64.tar.gz"
```

When importing the tarball is complete, run

```powershell
wsl -d Arch
```

You will be greeted with a root user prompt. Before anything is done, switch to the home directory with `cd`

### Making `pacman` work

```bash
sed -i 's:#Server:Server:g' /etc/pacman.d/mirrorlist
```

### Initializing the keyring and populating it

```bash
pacman-key --init && pacman-key --populate archlinux
```

### Installing some required packages

```bash
pacman -Syy --noconfirm base-devel git vim nano wget reflector sudo which go openssh man-db bash-completion fontconfig ntp
```

### Using reflector to find the fastest mirrors (here for Germany)

```bash
reflector --country "Germany" --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

### Setting root password and enabling sudo for users

```bash
export EDITOR=vim ; visudo
```

![wheel unedited](/assets/img/posts/installing-arch-on-wsl-the-right-way/uncomment-suders-file.png)

Uncomment the line containing `%wheel ALL=(ALL) ALL`; do the same to the next line with `%wheel` if you want to run sudo tasks without having to provide your password.

Now set the root user password with `passwd`. Do this before setting up the login user account. Once the root user has a password, create a user and prompt to set a password.

### Creating a user and giving a password

```bash
useradd -m -G wheel -s /bin/bash -d /home/michael michael ; passwd michael
```

Because **Archlinux** was imported, by default the login user is the root user even with a user account. To prevent this, a config file needs to be created to tell `wsl` which user to log in. Create the file `/etc/wsl.conf` and copy the following, replacing 'michael' with your own username.

[Settings for wsl.conf](https://learn.microsoft.com/en-us/windows/wsl/wsl-config)

```ini
[automount]
enabled = true
options = "metadata,uid=1000,gid=1000,umask=22,fmask=11,case=off"
mountFsTab = true
crossDistro = true

[network]
generateHosts = truenning with systemd, otherwise
# false.
generateResolvConf = true

[interop]
enabled = true
appendWindowsPath = true

[user]
default = michael

[boot]
systemd=true
```

## Finishing the setup process

If you use `Windows Terminal`, the best way is close it, then reopen it; a new profile for **Arch** has been added. To change the starting directory for **Arch**, goto settings and locate the profile for **Arch**. Find "Starting Directory" and replace it with `\\wsl$\Arch\home\michael`, replacing 'michael' with your own username. Then click save.

```bash
sudo systemctl status
```

If `systemd` is functional, you should see a green indication, and you can create your own systemctl scripts, but before that, let's first enable some services.

```bash
sudo systemctl enable --now dbus.service ntpd.service sshd.service
```

## Installing and aur helper such as yay

```bash
git clone https://aur.archlinux.org/yay-bin
cd yay-bin
makepkg -si --noconfirm
```

## Adjust locale

```bash
sudo vim /etc/locale.gen
```

uncomment `de_DE.UTF-8 UTF-8` and `en_US.UTF-8 UTF-8`

Then run

```bash
sudo locale-gen
sudo su
echo "LANG=en_US.UTF-8
LANGUAGE=en_US
LC_CTYPE=de_DE.UTF-8
LC_NUMERIC=de_DE.UTF-8
LC_TIME=de_DE.UTF-8
LC_COLLATE=de_DE.UTF-8
LC_MONETARY=de_DE.UTF-8
LC_MESSAGES=en_US.UTF-8
LC_PAPER=de_DE.UTF-8
LC_NAME=de_DE.UTF-8
LC_ADDRESS=de_DE.UTF-8
LC_TELEPHONE=de_DE.UTF-8
LC_MEASUREMENT=de_DE.UTF-8
LC_IDENTIFICATION=de_DE.UTF-8
LC_ALL=
" > /etc/locale.conf
```

### Optional: Enabling `multilib`

```bash
linenumber=$(grep -nr "\\#\\[multilib\\]" /etc/pacman.conf | gawk '{print $1}' FS=":")
sed -i "${linenumber}s:.*:[multilib]:" /etc/pacman.conf
linenumber=$((linenumber+1))
sed -i "${linenumber}s:.*:Include = /etc/pacman.d/mirrorlist:" /etc/pacman.conf
```
