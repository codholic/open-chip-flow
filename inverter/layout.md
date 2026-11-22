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

## Step 3.3: Place the PMOS and line it up

1. Left-click an empty spot **above** the NMOS (new devices appear at the box).
2. **Devices 1 → pmos (MOSFET)**: **Width `2`**, **Length `0.15`**, **Fingers `1`** → **Apply**.
3. `writeall force`.

You should see: a PMOS with tan p-diffusion inside a hatched **n-well** (its body is n-type and goes to VDD).

### Line up the two transistors

Magic has **no align command**. Read the positions, then move by the difference. In tkcon:

    units microns
    cellname list children
    select cell sky130_fd_pr__nfet_01v8_XXXXXX_0
    select bbox
    select cell sky130_fd_pr__pfet_01v8_YYYYYY_0
    select bbox

| Command | What it does |
|---|---|
| `cellname list children` | lists the instance names in your layout |
| `select cell NAME_0` | selects one instance. Use the **instance** name (ends in `_0`), not the file name (`.mag`) |
| `select bbox` | prints the selection's corners: left bottom right top |

Compare the two **left** numbers. Move the PMOS by the difference (here 0.64 µm to the right), then save:

    move e 0.64um
    select clear
    writeall force

`move e/w/n/s DIST` moves the selection right/left/up/down.

## Step 3.4: Wire it with a script

Instead of drawing wires with the mouse, all the boxes went into a small script that ran in one go:

{: .why }
**Done with Claude (AI assistant).** Claude read the transistor files, worked out the coordinates, wrote `wire_inverter.tcl`, and tested it on a copy of the layout (DRC, extraction, LVS) before I ran it. I only typed the `source` line below. Everything it did is explained in the rest of this step, so you can do it by hand or write your own script.


    source /foss/designs/inverter/mag/wire_inverter.tcl

Script: [wire_inverter.tcl]({{ '/assets/files/wire_inverter.tcl' | relative_url }}). `source` runs every line in it, as if typed into tkcon.

You should see: `wire_inverter.tcl done`, then `y` (mouse over the layout) gives **No errors found** and the counter shows **DRC=0**.

![Wired inverter, DRC=0: metal1 for in and out between the transistors, local interconnect from each source to its guard ring]({{ '/assets/img/inverter/3-4-wired-drc0.png' | relative_url }})

### What gets connected

| Net | How |
|---|---|
| `in` | metal1 from the NMOS gate contact (top) to the PMOS gate contact (bottom) |
| `out` | metal1 from both drains (right contact column), joined by a vertical wire on the right |
| `VDD` | PMOS source (left column) tied to the PMOS guard ring (n-tap = body) with local interconnect (`locali`) |
| `GND` | NMOS source tied to the NMOS guard ring (p-tap = body) with `locali` |
| extra | the two unused gate contacts are enlarged with metal1 so they meet the minimum area |

Each wire is two lines: `box x1 y1 x2 y2` sets the box to exact corners (lower-left, upper-right, in µm), `paint LAYER` fills it.

### How the box coordinates were found

No mouse, no guessing: everything comes from the saved files.

1. **Where each transistor sits.** `inverter.mag` has one `use` line per instance, followed by `transform 1 0 X 0 1 Y`: the instance center in **internal units**. Here NMOS = (164, 255), PMOS = (164, 1272).
2. **Where the metal is inside each transistor.** Each transistor file (`sky130_fd_pr__nfet_01v8_….mag`) lists its shapes under headers like `<< metal1 >>` and `<< locali >>`, one `rect x1 y1 x2 y2` per piece, relative to the transistor's center.
3. **Add them up.** Absolute position = transistor center + rect. Internal unit = **0.005 µm** (sky130 in Magic: 2 internal units = 1 lambda = 0.01 µm).
   Example, NMOS top gate contact: metal1 `rect -29 132 29 178` + (164, 255) = 135…193 by 387…433 → **0.675…0.965 µm** by **1.935…2.165 µm**. The `in` wire starts there.
4. **Keep the sky130 rules** while choosing the wire boxes:

| Rule | sky130 value | Meaning |
|---|---|---|
| met1.1 | width ≥ 0.14 µm | thinnest metal1 |
| met1.2 | spacing ≥ 0.14 µm | gap between two metal1 shapes |
| met1.6 | area ≥ 0.083 µm² | smallest metal1 piece |
| li | width ≥ 0.17 µm | thinnest local interconnect |

For example, the `out` wire runs at x ≥ 1.30 µm so it stays more than 0.14 µm away from the `in` wire (ends at 0.965 µm).

### Why it worked in one go

Before I sourced it on the real design, Claude ran the script on a **copy** of the layout with Magic in batch mode (no window):

    magic -dnull -noconsole

with DRC (`drc check`, `drc why`), extraction (`extract all`, `ext2spice lvs`, `ext2spice`) and LVS (netgen, Step 5). Result: no DRC errors and `Circuits match uniquely`. Only then did I run it on the real files.

{: .fail }
Drawing wires by hand: a metal1 band across **both** source/drain contact columns **shorts** the transistor (source = drain). DRC does not see this; LVS does.

## Further reading

- [An Introduction to the MAGIC VLSI Design Layout System](https://terpconnect.umd.edu/~newcomb/vlsi/magic_tut/Magic_x3.pdf) (J. Wilinski, UMD, 19 pages). Part I explains the box, painting, labels, wiring, DRC and extraction; Part II is a step-by-step CMOS inverter layout. From 2003, with a generic lambda-based technology instead of sky130: the way Magic works is the same, but layer names and rule values differ.

## Next

[4. DRC](drc.html) and [5. LVS](lvs.html).
