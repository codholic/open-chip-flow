---
title: 2. Simulation
parent: Inverter flow
nav_order: 2
---

# 2. Simulation (testbench + ngspice)

You do not simulate `inverter.sch` itself. You make a **testbench**: a second schematic that powers the inverter, drives its input and tells ngspice what to run.

All commands run in the **terminal inside the tools desktop**.

## Step 2.1: Open a new testbench

    cd /foss/designs/inverter/xschem
    xschem tb_inverter.sch &

What it does: opens Xschem on a new, empty schematic `tb_inverter.sch` (`tb` = testbench), in the same folder as the inverter.

## Step 2.2: Place the inverter

1. `Shift+I` → click **Current dir** (bottom of the window) → select `inverter.sym` → **OK** → click on the canvas.

What it does: puts one copy (instance) of your inverter in the testbench.
You should see: the box from Step 1.7, now showing `inverter` in the middle and `x1` on top: the placeholders `@symname` and `@name` are filled in.

![Testbench with the inverter symbol placed as x1]({{ '/assets/img/inverter/2-2-tb-inverter-placed.png' | relative_url }})

{: .why }
`x1` is the instance name. SPICE uses names starting with `x` for subcircuits (blocks made of other parts). A second copy would be `x2`.

## Step 2.3: Add sources, ground, load and labels

`Shift+I` → **Home** → the line ending in `xschem_library/devices`. Place, then set each with `Q`:

| Symbol | Set | Why |
|---|---|---|
| `vsource.sym` (V1) | `value=1.8` | **supply**: powers the inverter |
| `vsource.sym` (V2) | `value="pulse(0 1.8 1n 100p 100p 5n 10n)"` | **input**: a square wave |
| `gnd.sym` (one per ground point) | — | ground = SPICE node `0`, the 0 V reference |
| `capa.sym` (C1) | `value=10f` | **load**: 10 fF, like the next gate the inverter drives |
| `lab_pin.sym` ×3 | `lab=VDD`, `lab=in`, `lab=out` | names the wires, so the plot can find them |

`pulse(0 1.8 1n 100p 100p 5n 10n)` = low 0 V, high 1.8 V, start after 1 ns, 100 ps rise, 100 ps fall, high for 5 ns, repeat every 10 ns.

### Wiring (`W`)

| From | To |
|---|---|
| V1 **+** | `VDD` label → x1 `VDD` |
| V2 **+** | `in` label → x1 `in` |
| x1 `out` | `out` label → C1 top |
| V1 **−**, V2 **−**, C1 bottom, x1 `GND` | `gnd` |

A `vsource` has **+** at the top (marked with a small `+`).

{: .fail }
x1 `GND` not wired to `gnd`? Then the inverter has no ground and the output floats.

## Step 2.4: Add the simulation commands

Place `code_shown.sym` (also in `devices`), select it, `Q`, and set (**with the quotes**):

    value=".lib /foss/pdks/sky130A/libs.tech/ngspice/sky130.lib.spice tt
    .control
    tran 10p 40n
    plot v(in) v(out)
    .endc"

| Line | What it does |
|---|---|
| `.lib … sky130.lib.spice tt` | loads the sky130 transistor models, typical (`tt`) corner |
| `.control` … `.endc` | commands ngspice runs by itself |
| `tran 10p 40n` | transient simulation: 40 ns of time in 10 ps steps |
| `plot v(in) v(out)` | opens a window with the two voltages |

`Ctrl+S` to save.

You should see: the box shows all 5 lines.

![Complete testbench: inverter x1, supply V1, pulse source V2, load C1, ground, labels and the code block]({{ '/assets/img/inverter/2-3-testbench-complete.png' | relative_url }})

{: .fail }
Box shows only `.lib`? The quotes are missing: without `"…"` Xschem keeps only the first word.

## Step 2.5: Make the netlist

Click **Netlist** (top bar).

What it does: writes the schematic as a SPICE text file, `tb_inverter.spice`, in `~/.xschem/simulations/` inside the tools. This text is what ngspice reads.
You should see: a window with the netlist (if your Xschem is set to show it). **Dismiss** closes it.

![Netlist window of tb_inverter.spice]({{ '/assets/img/inverter/2-5-netlist.png' | relative_url }})

How to read it:

| Line | Meaning |
|---|---|
| `x1 VDD in out 0 inverter` | the inverter instance, pins in symbol order; ground is node `0` |
| `V1 VDD 0 1.8` | supply: 1.8 V from VDD to ground |
| `V2 in 0 pulse(...)` | input square wave |
| `C1 out 0 10f` | load capacitor |
| `.subckt inverter VDD in out GND` … `.ends` | what is inside the inverter |
| `XM1 out in VDD VDD … pfet_01v8 L=0.15 W=2` | PMOS, pins **D G S B** = out, in, VDD, VDD |
| `XM2 out in GND GND … nfet_01v8 L=0.15 W=1` | NMOS, pins **D G S B** = out, in, GND, GND |

{: .why }
Check the netlist before simulating: every wrong wire shows up here as a wrong net name. For example, a floating body would appear as `net1` instead of `VDD`/`GND`.

## Next

Step 2.6 (run the simulation, see the waveforms) comes after I do it.
