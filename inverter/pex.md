---
title: 6. Post-layout simulation
parent: Inverter flow
nav_order: 6
---

# 6. Post-layout simulation

The schematic simulation (Step 2) only knows the transistors. The real layout adds **parasitics**: capacitance between wires, from wires to ground, and from the source/drain junctions. Post-layout simulation extracts them from the layout and simulates again, so you see how much slower the real circuit is.

{: .why }
**Done by Claude (AI assistant).** Claude wrote the extraction script and the side-by-side testbench, found and fixed a pin-order mismatch, and tested everything on copies of my files first. I ran the script and the simulation.

## Before you start: pin order must match

The extracted netlist will be plugged into the Xschem **symbol** of the inverter, so its pins must be in the **same order** as the symbol: `VDD in out GND`.
Magic orders pins by their **port number**, which is the order they were created with `port make`.

Check after extracting: the line must read `.subckt … VDD in out GND`. If not, the pins get crossed and the simulation gives nonsense (negative delays, "out of interval").

{: .fail }
My first layout had `in out VDD GND` (ports made in that order). Fix used here: with Magic closed, back up `inverter.mag` and change the four `port N` lines under `<< labels >>` to VDD 1, in 2, out 3, GND 4. Then re-run LVS to confirm. Better: create the ports in the symbol's order from the start (the [wiring script](../assets/files/wire_inverter.tcl) now does).

## Step 6.1: Extract with parasitic capacitances

Open Magic in `mag/`, then in tkcon:

    source /foss/designs/inverter/mag/extract_pex.tcl

Script: [extract_pex.tcl]({{ '/assets/files/extract_pex.tcl' | relative_url }}). It runs:

| Command | What it does |
|---|---|
| `extract all` | find devices, connections **and** capacitances; write `.ext` files |
| `ext2spice lvs` | sky130 device names, cells as subcircuits |
| `ext2spice cthresh 0` | keep **every** parasitic capacitance (threshold 0 fF); `lvs` mode alone would drop them |
| `ext2spice -o inverter_pex.spice` | write the netlist |
| rename `.subckt inverter` → `.subckt inverter_parax` | so Xschem can use it next to the schematic `inverter` (Step 6.2) |

You should see: `extract_pex.tcl done: wrote inverter_pex.spice (.subckt inverter_parax)`.

![tkcon after source extract_pex.tcl]({{ '/assets/img/inverter/6-1-extract-pex.png' | relative_url }})

The top cell in `inverter_pex.spice`:

    .subckt inverter_parax VDD in out GND
    Xsky130_fd_pr__nfet_01v8_34VMYE_0 GND GND out in sky130_fd_pr__nfet_01v8_34VMYE
    Xsky130_fd_pr__pfet_01v8_VJT448_0 VDD VDD out in GND sky130_fd_pr__pfet_01v8_VJT448
    C0 out VDD 0.08563f
    C1 VDD in 0.04275f
    C2 out in 0.12694f
    C3 in GND 0.13012f
    C4 out GND 0.25983f
    C5 VDD GND -0.04326f
    .ends

Each `C` line is a parasitic capacitor between two nets, in fF (for example `out` to `GND`). The transistor cells above it have their own junction capacitances. (A tiny negative value like `VDD GND -0.04f` comes from Magic's coupling correction and is harmless.)

## Step 6.2: Simulate schematic and layout side by side

Testbench: `xschem/tb_inverter_pex.sch` (made by Claude from `tb_inverter.sch`):

| Instance | What it is | Output |
|---|---|---|
| `x1` | the **schematic** inverter (`inverter.sch`) | `out` |
| `x2` | the **extracted layout** with parasitics (`inverter_pex.spice`) | `out_pex` |

Both get the same input `in`, the same 1.8 V supply and the same 10 fF load.

`x2` is the same `inverter.sym`, with two extra properties (`Q` on it):

    schematic=inverter_parax
    spice_sym_def="tcleval(.include /foss/designs/inverter/mag/inverter_pex.spice)"

| Property | What it does |
|---|---|
| `schematic=inverter_parax` | this instance becomes subcircuit `inverter_parax` in the netlist, not `inverter` |
| `spice_sym_def=…` | instead of netlisting the schematic, Xschem includes the extracted file, which defines `inverter_parax` |

{: .fail }
With only `spice_sym_def` (no `schematic=`), Xschem quietly kept using the schematic. With `schematic=` but the extracted subcircuit still called `inverter`: `unknown subckt … inverter_parax`. That is why `extract_pex.tcl` renames it.

The code block measures the delay of both outputs (50 % = 0.9 V crossing of `in` to 0.9 V crossing of the output):

    meas tran tphl_sch trig v(in) val=0.9 rise=1 targ v(out) val=0.9 fall=1
    meas tran tplh_sch trig v(in) val=0.9 fall=1 targ v(out) val=0.9 rise=1
    meas tran tphl_pex trig v(in) val=0.9 rise=1 targ v(out_pex) val=0.9 fall=1
    meas tran tplh_pex trig v(in) val=0.9 fall=1 targ v(out_pex) val=0.9 rise=1
    write tb_inverter_pex.raw

| `meas` part | Meaning |
|---|---|
| `tphl` / `tplh` | delay when the output goes high→low / low→high |
| `trig v(in) val=0.9 rise=1` | start the clock when `in` crosses 0.9 V going up, the 1st time |
| `targ v(out) val=0.9 fall=1` | stop it when `out` crosses 0.9 V going down, the 1st time |

Run: **Netlist** → **Simulate**. Then `quit` in the ngspice terminal, and **Ctrl+click** "load waves".

![Testbench with x1 (inverter) and x2 (inverter_parax), graph of in/out/out_pex, and the four delays in the ngspice terminal]({{ '/assets/img/inverter/6-2-sim-side-by-side.png' | relative_url }})

## Result

| Delay | Schematic (`out`) | Layout + parasitics (`out_pex`) | Difference |
|---|---|---|---|
| tpHL (output falls) | 48.8 ps | 51.9 ps | +3.1 ps (+6 %) |
| tpLH (output rises) | 57.7 ps | 61.5 ps | +3.8 ps (+7 %) |

The layout adds a few femtofarads on `out` (wire and junction capacitance), so the inverter charges more capacitance and is about **6–7 % slower**. Rising is slower than falling in both cases: the PMOS is 2× wider, but holes are still slower than that.

## Step 6.3: Zoom in on one edge

At 0–40 ns the 3 ps gap is invisible. Zoom on the first falling edge: select the graph **border**, `Q`, set

    x1=1.0e-9
    x2=1.25e-9

**OK**.

![Zoom 1.0 to 1.25 ns: in rising, out and out_pex falling, out_pex slightly later]({{ '/assets/img/inverter/6-2-zoom-falling-edge.png' | relative_url }})

You should see: `in` rising, `out` and `out_pex` falling, `out_pex` slightly to the right (later). The small bump above 1.8 V at the start is the input coupling to the output through the gate-drain capacitance.

Other ways to zoom: right-drag left↔right inside the plot (on a Mac trackpad: two-finger click and drag), `f` for the full view. Rising edge: `x1=6.0e-9 x2=6.3e-9`.

{: .why }
Xschem graphs have no dotted/dashed line style: waves differ by color only. To see the gap as its own trace, add `"delta; out_pex out -"` to `node` (one more color in `color`): `out_pex` minus `out`.

## Done

The inverter has gone through the whole flow: schematic → simulation → layout → DRC → LVS → post-layout simulation.
