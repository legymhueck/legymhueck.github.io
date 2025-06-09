---
title: Adding a directory to the PATH variable in Windows
description: How to add a directory to the PATH variable in Windows using cmd or PowerShell.
author: legymhueck
date: 2025-06-09 10:34:00 +0200
categories: [Tutorial, Windows]
tags: [windows, path, environment variable, cmd, powershell]
---

## Set path in windows

```cmd
set Path=C:\Users\MicLeh\.local\bin;%Path%
```

```powershell
$env:Path = "C:\Users\MicLeh\.local\bin;$env:Path"
```
