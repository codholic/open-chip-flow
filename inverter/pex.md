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

## Step 6.4: How big is the gap, and why?

{: .why }
**Analysis by Claude (AI assistant):** Claude read the four delays from my ngspice terminal, added up the parasitic capacitors in `inverter_pex.spice`, and ran extra ngspice sweeps (load and transistor size) to check the explanation.

![Zoomed falling edge and the four meas results in the ngspice terminal]({{ '/assets/img/inverter/6-4-delays-terminal.png' | relative_url }})

### 1. The gap, from the ngspice terminal

    tphl_sch = 4.88492e-11   tphl_pex = 5.19442e-11
    tplh_sch = 5.76643e-11   tplh_pex = 6.14968e-11

| | Schematic | Layout | Gap | Gap in % |
|---|---|---|---|---|
| tpHL | 48.85 ps | 51.94 ps | 51.94 − 48.85 = **3.10 ps** | 3.10 / 48.85 = **6.3 %** |
| tpLH | 57.66 ps | 61.50 ps | 61.50 − 57.66 = **3.83 ps** | 3.83 / 57.66 = **6.6 %** |
| average tp = (tpHL + tpLH) / 2 | 53.3 ps | 56.7 ps | 3.5 ps | 6.5 % |

### 2. How much capacitance is that?

Delay grows almost linearly with the load capacitance. Measured with the schematic inverter (10 → 11 → 12 fF load):

| Load | tpHL | tpLH |
|---|---|---|
| 10 fF | 49.0 ps | 57.7 ps |
| 11 fF | 51.0 ps | 60.2 ps |
| 12 fF | 52.9 ps | 62.7 ps |
| **slope** | **≈ 1.95 ps per fF** | **≈ 2.5 ps per fF** |

So the layout behaves like **extra load** of

- falling: 3.10 ps ÷ 1.95 ps/fF ≈ **1.6 fF**
- rising: 3.83 ps ÷ 2.5 ps/fF ≈ **1.5 fF**

### 3. Where that capacitance is (from `inverter_pex.spice`)

Adding up every `C` line that touches `out` (top cell plus both transistor cells):

| `out` to | Capacitors | Sum |
|---|---|---|
| GND | 0.260 + 0.087 + 0.250 + 0.108 | 0.71 fF |
| VDD | 0.086 + 0.121 + 0.173 | 0.38 fF |
| `in` | 0.127 + 0.027 + 0.040 = 0.19 fF, counted **×2** (Miller effect: `in` and `out` swing in opposite directions) | ≈ 0.39 fF |
| **total** | | **≈ 1.5 fF** |

Same answer as step 2: about **1.5 fF of layout parasitics** on top of the 10 fF load. That is why the layout is ~6.5 % slower.

### 4. Would smaller transistors help? No.

A smaller transistor has less junction capacitance, but it also gives **less current**. Delay ≈ C / I, so both shrink together:

| Wn / Wp | Load 10 fF: tpHL / tpLH | Load ≈ 0: tpHL / tpLH |
|---|---|---|
| 0.5 / 1 | 68.3 / 82.8 ps (**slower**) | 19.0 / 23.3 ps |
| 1 / 2 (this design) | 49.0 / 57.7 ps | 19.3 / 23.7 ps |
| 2 / 4 | 35.7 / 44.2 ps (faster) | 17.5 / 23.4 ps |

- With a **real load** (10 fF), the load dominates: halving the transistors makes it ~40 % **slower**; doubling makes it ~27 % faster (but then the inverter loads the stage before it more).
- With **no load**, the delay is the same for every size: the transistor drives mostly its own capacitance, which scales with it.

### 5. How to reduce the layout parasitics

The ~1.5 fF comes from the **layout**, so the fixes are in the layout:

| Fix | Which capacitance it cuts |
|---|---|
| Put the PMOS and NMOS closer (gap here: 1.44 µm) | shorter `in` and `out` wires: less wire to GND/VDD |
| Make the `out` wire short and not wider than needed, and not run over the guard rings | `out`–GND (0.26 fF in the top cell) |
| Keep the `in` and `out` wires apart, not running side by side | `in`–`out` coupling, which counts double (Miller) |
| Remove the unused gate contacts (`topc` / `botc` = 0) | extra poly/metal on `in` |
| Use 2 fingers (`nf=2`) with the drain in the middle | the two halves share one drain: about half the drain junction area on `out` |
| Long wires on higher metal (metal2/3) | farther from the substrate: less capacitance per µm |

For this tiny inverter, 1.5 fF next to a 10 fF load is small. In a real block (like a SAR ADC comparator, where the load is small and the wires are long), the layout parasitics can dominate, so these habits matter.

## Done

The inverter has gone through the whole flow: schematic → simulation → layout → DRC → LVS → post-layout simulation.
