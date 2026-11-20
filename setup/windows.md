---
title: Windows
parent: 0. Setup
nav_order: 2
---

# Setup on Windows

{: .untested }
Written from the official [IIC-OSIC-TOOLS README](https://github.com/iic-jku/iic-osic-tools). If you try it, please report what happened.

## Step 1: Turn on WSL2

In **PowerShell as Administrator**:

    wsl --install

What it does: installs WSL2 (Linux inside Windows), which Docker Desktop needs. Restart when asked.

## Step 2: Install Docker Desktop

Download and run: [Docker Desktop Installer](https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe). Start it and wait until it says it is running.

## Step 3: Download the launcher scripts

Install [Git for Windows](https://git-scm.com/download/win), then in a terminal:

    git clone --depth=1 https://github.com/iic-jku/iic-osic-tools.git

(Or on the GitHub page: green **Code** button, then **Download ZIP** and unzip.)

## Step 4: Start the tools

Double-click `start_vnc.bat` in the `iic-osic-tools` folder.
The first time it downloads the tools image (big, takes a while).
Your design files live in `%USERPROFILE%\eda\designs` = `/foss/designs` inside the tools.

## Step 5: Open the tools desktop

Open <http://localhost/?password=abc123> in your browser. The start script prints the exact link.

## Step 6: Choose the sky130 PDK

Same as [Mac Step 6](mac.html#step-6-choose-the-sky130-pdk): make `%USERPROFILE%\eda\designs\.designinit` with the same lines.

## Step 7: Check it works

Same as [Mac Step 7](mac.html#step-7-check-it-works).
