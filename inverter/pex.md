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

## Next

Step 6.2 (simulate schematic and layout side by side) comes after I do it.
