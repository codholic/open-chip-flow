---
title: 1. Schematic
parent: Inverter flow
nav_order: 1
---

# 1. Inverter schematic (Xschem)

Goal: draw a CMOS inverter (one PMOS on top, one NMOS below) with the sky130 1.8 V transistors.
All commands run in the **terminal inside the tools desktop**.

## Step 1.1: Make the design folder

    mkdir -p /foss/designs/inverter/xschem
    cd /foss/designs/inverter/xschem

What it does: `mkdir -p` makes the folder (and `inverter/` above it). `cd` moves you into it.
On your computer this is `designs/inverter/xschem` in your design folder.

## Step 1.2: Open Xschem on a new schematic

    xschem inverter.sch &

What it does: opens Xschem with a new, empty schematic named `inverter.sch`. The `&` runs it in the background so the terminal stays free.
You should see: a black grid with `inverter.sch` in the title bar and on the tab.

The file is only written to disk when you save (`Ctrl+S`).

### The symbol window

Press `Shift+I` (or the **Insert** key) to open **Choose symbol**:

![Xschem with the Choose symbol window open]({{ '/assets/img/inverter/1-2-xschem-choose-symbol.png' | relative_url }})

- **Left:** the library folders. `.../xschem_library/devices` = generic parts (pins, sources, ground, labels). `.../sky130A/libs.tech/xschem` = the sky130 transistors.
- **Right:** the symbols in the chosen folder. **Search** filters them by name.

{: .fail }
`pmos.sym` / `nmos.sym` in `devices` are **generic** transistors with no sky130 model. Do not use them for this design. The sky130 ones are `pfet_01v8.sym` and `nfet_01v8.sym` under `sky130A/libs.tech/xschem` → `sky130_fd_pr` (Step 1.3).

## Step 1.3: Place the sky130 transistors

1. Press `Shift+I`. On the left, click the line ending in `sky130A/libs.tech/xschem`, then double-click `sky130_fd_pr` on the right.
2. Search `pfet_01v8`, select **`pfet_01v8.sym`** (check the **File:** box at the bottom), click **OK**, click on the canvas to place it.
3. Again `Shift+I`: place **`nfet_01v8.sym`** below it.
4. Press `F` to fit the view, `Ctrl+S` to save.

What it does: `pfet_01v8` / `nfet_01v8` are SkyWater's normal 1.8 V transistors (`fd_pr` = foundry primitives). Each starts at the default size `W=1 L=0.15` (shown as `1 x 1 / 0.15` = mult x W / L, in µm).

You should see: each transistor has **4 red pin squares: G, D, S and B** (B = body).

![Inverter schematic with pfet_01v8 and nfet_01v8 placed, pins added, gates and drains wired]({{ '/assets/img/inverter/1-3-transistors-placed.png' | relative_url }})

*(This picture is a little ahead: pins and some wires from Steps 1.5 and 1.6 are already there. The B pins are not wired yet.)*

{: .fail }
Only **3** pin squares and the body written as text (`VDD` / `GND`)? You placed **`pfet3_01v8` / `nfet3_01v8`**, the 3-terminal versions whose body is fixed by a property. Delete it (`Del`) and place `pfet_01v8.sym` / `nfet_01v8.sym`. The `pfet_01v8` label alone does not tell you, because both versions use the same model name.

## Next

Step 1.4 (set the sizes) comes after I do it.

{: .fail }
Alert "`.../sky130_fd_pr/doc/pfet_01v8.svg` does not seem to be an xschem file": Search also finds the **picture** `pfet_01v8.svg` in the `doc/` folder. Click **No**, then pick `pfet_01v8.sym` (ends in `.sym`, not inside `doc/`).

## Xschem keys used on this page

| Key | Does |
|---|---|
| `Shift+I` or `Insert` | Choose symbol |
| `Q` | Edit properties of the selected item |
| `W` | Draw a wire |
| `M` / `C` | Move / copy the selection |
| `F` | Zoom to fit everything |
| `Esc` | Cancel |
| `Ctrl+S` | Save |
| `A` | Make a symbol from this schematic |
