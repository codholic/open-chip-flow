---
title: 3. Layout
parent: Inverter flow
nav_order: 3
---

# 3. Inverter layout (Magic)

The layout is the **physical** inverter: the shapes of diffusion, poly and metal that are made in the factory.
Goal: the same two transistors as the schematic (PMOS W=2, NMOS W=1, L=0.15), connected with metal, with labels on `in`, `out`, `VDD`, `GND`.

All commands run in the **terminal inside the tools desktop**.

## Step 3.1: Open Magic

    mkdir -p /foss/designs/inverter/mag
    cd /foss/designs/inverter/mag
    magic inverter.mag &

What it does: makes a `mag/` folder next to `xschem/`, moves into it, and opens Magic on a new layout called `inverter`.
Magic loads the sky130 technology by itself: `~/.magicrc` reads `$PDK` (sky130A, from [Setup Step 6](../setup/mac.html#step-6-choose-the-sky130-pdk)).

You should see two windows:

- the **layout window**: menus **Devices 1 / Devices 2** (sky130 parts), a **DRC** checkbox (live rule checking), and the **layer list** on the right
- the **tkcon** console: Magic's messages, and a prompt to type commands

![Magic layout window with sky130 menus and layer list]({{ '/assets/img/inverter/3-1-magic-open.png' | relative_url }})

{: .why }
Title says `layout1` instead of `inverter`? Magic was started without a file name. No problem: name it when saving, by typing `save inverter` in the tkcon console.

## Next

Step 3.2 (place the transistors) comes after I do it.
