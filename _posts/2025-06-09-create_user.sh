---
title: Script to create a new user
author: legymhueck
date: 2025-06-09 16:34:00 +0200
categories: [Tutorial]
tags: [bash, sh]
---

```bash
#!/bin/bash

# Prompt the user for the new username
read -p "Enter the username for the new user: " new_user

# Check if the username is already taken
if id -u "$new_user" >/dev/null 2>&1; then
  echo "Error: User '$new_user' already exists."
  exit 1
fi

# Define the array of groups
groups=(
  adm audio autologin disk floppy input libvirt sys log network scanner power
  rfkill users video storage optical lp wheel kvm docker
)

# Create the new user and add them to the specified groups
sudo useradd -G "${groups[*]}" "$new_user"

# Prompt the user to set a password for the new user
echo "New user '$new_user' created. You will now be prompted to set a password."
sudo passwd "$new_user"

echo "User '$new_user' has been successfully created and added to the specified groups."
```