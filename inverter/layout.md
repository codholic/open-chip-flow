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

{: .fail }
Files saved in the wrong folder? Magic saves into the folder it was **started from**. Check with `pwd` in tkcon; change it with `cd /foss/designs/inverter/mag`.

{: .why }
The window title can stay `layout1` even after `save inverter`. Check the saved file with `ls` in the terminal instead.

## Step 3.2: Place the NMOS

1. Layout window: **Devices 1 → nmos (MOSFET)**.
2. In the parameter window set **Width `1`**, **Length `0.15`**, **Fingers `1`**. Leave the rest as it is.
3. Click **Apply** / **OK**.

What it does: Magic builds a complete sky130 NMOS for you (a **PCell** = parameterized cell): green n-diffusion, the poly gate across it, contacts on source and drain and on the gate, and a guard ring around it (the body connection).

{: .fail }
The width box starts at **0.42** (the smallest allowed). Change it before Apply, or the transistor will not match the schematic and LVS fails later.

You should see: the status bar says `Loaded: inverter  Editing: inverter`, and the transistor shows its instance name (`sky130_fd_pr__nfet_01v8_XXXXXX_0`).

![NMOS W=1 L=0.15 placed in the inverter cell, with guard ring and gate contacts top and bottom]({{ '/assets/img/inverter/3-2-nmos-placed.png' | relative_url }})

To change a placed transistor: mouse over it, `s` (select), `q` (parameter window), edit, **Apply**.

{: .fail }
`q` says **No gencell device is selected** and `s` says **Topmost cell in the window**? The window shows the transistor's own cell instead of `inverter`. In tkcon: `load inverter`. If Magic asks what to do with the transistor cell, click **flush** (throw away its unsaved changes), then place the transistor again.

### Check DRC

The **DRC** box at the top shows the number of rule errors. To see what they are, in tkcon:

    select top cell
    drc why

![tkcon showing drc why: Metal1 minimum area (met1.6)]({{ '/assets/img/inverter/3-2-drc-why.png' | relative_url }})

`Metal1 minimum area < 0.083um^2 (met1.6)`: each contact has a tiny metal1 square, smaller than sky130 allows. Normal for a transistor that is not wired yet: it disappears once the metal1 wires are drawn.

### Save everything

    writeall force

What it does: saves every changed cell. `save inverter` saves only the top cell; the transistor lives in its own file (`sky130_fd_pr__nfet_01v8_XXXXXX.mag`) and would be missing next time.

You should see: `ls` in `mag/` shows `inverter.mag` and a `sky130_fd_pr__nfet_01v8_….mag` file.

## Next

Step 3.3 (the PMOS) comes after I do it.
