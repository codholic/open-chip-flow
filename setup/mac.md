---
title: Mac
parent: 0. Setup
nav_order: 1
---

# Setup on a Mac

Tested on an Apple-silicon MacBook (2026-10-29).

## Step 1: Install Homebrew (skip if you have it)

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

What it does: installs Homebrew, the Mac's app installer for the Terminal.
You should see: `brew --version` prints a version.

## Step 2: Install Docker Desktop

    brew install --cask docker

What it does: installs the Docker Desktop app (`--cask` = a normal Mac app with a window).
Then open it once: `open -a Docker`. Skip the sign-in.
You should see: a whale icon in the top menu bar. Wait until it stops moving.

## Step 3: Download the launcher scripts

    mkdir -p ~/eda && cd ~/eda
    git clone --depth=1 https://github.com/iic-jku/iic-osic-tools.git

What it does: downloads only the start scripts (small). The tools themselves come in Step 4.
You should see: a folder `~/eda/iic-osic-tools`.

## Step 4: Start the tools

    cd ~/eda/iic-osic-tools
    ./start_vnc.sh

What it does: downloads the tools image the first time (big, ~17 GB on disk, takes a while), then starts it.
Your design files live in `~/eda/designs` on the Mac = `/foss/designs` inside the tools.

{: .why }
Want your design files in another folder? Start it once with `DESIGNS=~/your/folder ./start_vnc.sh`. The tools remember that folder. If the tools were already set up before, the script just restarts the old ones (with their old folder).

{: .fail }
"Cannot connect to the Docker daemon" means Docker Desktop is not running. Do Step 2's `open -a Docker` and wait for the whale.

## Step 5: Open the tools desktop

Open this in your browser: <http://localhost/?password=abc123>

You should see: a Linux desktop in the browser tab. `abc123` is the default password.

## Step 6: Choose the sky130 PDK

The tools start with the IHP PDK by default. To use sky130, make the file `~/eda/designs/.designinit` with:

    export PDK=sky130A
    export PDKPATH=$PDK_ROOT/$PDK
    export STD_CELL_LIBRARY=sky130_fd_sc_hd
    export SPICE_USERINIT_DIR=$PDKPATH/libs.tech/ngspice
    export KLAYOUT_PATH=$PDKPATH/libs.tech/klayout

What it does: every new terminal inside the tools reads this file, so all tools use sky130.

{: .why }
Without it, Xschem shows the wrong device libraries and Magic loads the wrong technology.

## Step 7: Check it works

In a terminal **inside the browser desktop**:

    echo $PDK
    xschem &

You should see: `sky130A`, then the Xschem window opens.

## Every day after that

| To | Run in the Mac Terminal |
|---|---|
| Start | `open -a Docker`, wait for the whale, then `docker start iic-osic-tools_xvnc_uid_$(id -u)` and open the link from Step 5 |
| Stop | `docker stop iic-osic-tools_xvnc_uid_$(id -u)` |

Your files in `~/eda/designs` stay when you stop.

{: .fail }
While the tools are running, create, rename and delete design files **inside the browser desktop**, not in Finder. Otherwise the tools can keep seeing old copies (Docker file-sharing cache). Fix: stop and start again.
