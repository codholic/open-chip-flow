---
title: Linux
parent: 0. Setup
nav_order: 3
---

# Setup on Linux

{: .untested }
Written from the official [IIC-OSIC-TOOLS README](https://github.com/iic-jku/iic-osic-tools).

## Step 1: Install Docker Engine

Follow [docs.docker.com/engine/install](https://docs.docker.com/engine/install/), then the [post-install steps](https://docs.docker.com/engine/install/linux-postinstall/) so you can run Docker without `sudo`.

{: .fail }
Do not run the start scripts with `sudo`. Your files would end up owned by root.

## Step 2: Download the launcher scripts

    mkdir -p ~/eda && cd ~/eda
    git clone --depth=1 https://github.com/iic-jku/iic-osic-tools.git

## Step 3: Start the tools

    cd ~/eda/iic-osic-tools
    ./start_vnc.sh

## Steps 4 to 6

Same as [Mac Steps 5 to 7](mac.html#step-5-open-the-tools-desktop).
