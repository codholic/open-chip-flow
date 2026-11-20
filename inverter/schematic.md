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

   ![Choose symbol in sky130_fd_pr with pfet_01v8.sym selected]({{ '/assets/img/inverter/1-3-choose-pfet.png' | relative_url }})

3. Again `Shift+I`: place **`nfet_01v8.sym`** below it.
4. Press `F` to fit the view, `Ctrl+S` to save.

What it does: `pfet_01v8` / `nfet_01v8` are SkyWater's normal 1.8 V transistors (`fd_pr` = foundry primitives). Each starts at the default size `W=1 L=0.15` (shown as `1 x 1 / 0.15` = mult x W / L, in µm).

You should see: each transistor has **4 red pin squares: G, D, S and B** (B = body).

![Inverter schematic with pfet_01v8 and nfet_01v8 placed, pins added, gates and drains wired]({{ '/assets/img/inverter/1-3-transistors-placed.png' | relative_url }})

*(This picture is a little ahead: pins and some wires from Steps 1.5 and 1.6 are already there. The B pins are not wired yet.)*

## Step 1.4: Set the transistor sizes

1. Click the PMOS (M1), press `Q`.
2. In **Edit Properties** change `W=1` to `W=2`. Leave `L=0.15`.
3. Click **OK**, then `Ctrl+S`.
4. The NMOS (M2) stays at `W=1 L=0.15`.

| Transistor | W (µm) | L (µm) |
|---|---|---|
| PMOS M1 | 2 | 0.15 |
| NMOS M2 | 1 | 0.15 |

{: .why }
`L=0.15` µm is the shortest length sky130 allows, so the transistors are as fast as possible. Holes (PMOS) move about 2–3× slower than electrons (NMOS), so the PMOS is made wider to give similar rise and fall times.

![Edit Properties window of M1 with W=2]({{ '/assets/img/inverter/1-4-edit-properties.png' | relative_url }})

The other lines (`ad`, `pd`, `as`, `ps`, `nrd`, `nrs`) are formulas for the drain/source area and perimeter. They update from `W` by themselves: leave them alone.
`Path` at the top shows which symbol file this is: it must end in `sky130_fd_pr/pfet_01v8.sym`.

You should see: the PMOS label changes to `1 x 2 / 0.15`.

{: .fail }
Value did not change? The new value is only kept after **OK**, and only saved to the file after `Ctrl+S` (a `*` in the title means unsaved).

## Step 1.5: Add the pins

Pins are how the inverter connects to the outside world (the testbench, or a bigger circuit).

1. `Shift+I` → **Home** → the line ending in `xschem_library/devices` (pins are **not** inside `sky130_fd_pr`).
2. Place and name them (select, `Q`, set `lab=`):

| Symbol | `lab=` | Meaning |
|---|---|---|
| `ipin.sym` | `in` | input |
| `opin.sym` | `out` | output |
| `iopin.sym` | `VDD` | supply |
| `iopin.sym` | `GND` | ground |

{: .why }
Do **not** use `vdd.sym` / `gnd.sym` here. Those are global supply/ground for the testbench (Step 2). Inside a building block, power comes in through pins.

## Step 1.6: Wire it

Press `W`, click a start point, click the end point (`Shift+W` snaps to the nearest pin). `Esc` stops.

| From | To |
|---|---|
| both gates (G) | `in` |
| both drains (D) | `out` |
| PMOS source (S) **and body (B)** | `VDD` |
| NMOS source (S) **and body (B)** | `GND` |

A blue dot means wires are joined. Then `Ctrl+S`.

{: .fail }
Forgot the **B** wires? The body then floats: wrong threshold voltage in simulation and an LVS error later.

## Step 1.7: Make the symbol

In `inverter.sch` press `A` (Make symbol from pin list), accept, then `Ctrl+S`.

What it does: writes `inverter.sym` next to `inverter.sch`: a box with your 4 pins, so the inverter can be dropped into other schematics (like the testbench in Step 2).
To open it: File → Open → `inverter.sym`.

![The generated inverter symbol: a box with pins in, VDD, out, GND]({{ '/assets/img/inverter/1-7-inverter-symbol.png' | relative_url }})

`@symname` and `@name` are placeholders: in a schematic they show the symbol name (`inverter`) and the instance name (e.g. `x1`).

You should see: `ls` in the terminal shows `inverter.sch` and `inverter.sym`.

## Next

[2. Simulation](simulation.html): a testbench that powers the inverter and plots in/out.

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
