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

## Next

Step 1.3 (place the sky130 transistors) comes after I do it.

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
