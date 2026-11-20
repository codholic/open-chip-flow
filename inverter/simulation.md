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

## Step 2.6: Run the simulation

Click **Simulate** (top bar).

What it does: opens a terminal and runs `ngspice` on the netlist. ngspice runs the commands between `.control` and `.endc`, so `plot` opens a waveform window.
You should see: `v(in)` (red) is a square wave and `v(out)` (blue) is the same wave **upside down**, both between 0 and 1.8 V.

![ngspice terminal and plot window: v(out) is the inverse of v(in)]({{ '/assets/img/inverter/2-6-simulation-plot.png' | relative_url }})

- **Plot window:** click a point to read its time and voltage (printed in the terminal as `x0 = …, y0 = …`). **Quit** closes it.
- **Terminal:** `Initial Transient Solution` lists the voltages at t = 0: `in` = 0, so `out` = 1.8 V (correct for an inverter). The prompt `ngspice 1 ->` waits for more commands; type `quit` to close.

{: .why }
The small spikes on `out` at each edge are normal: the input couples to the output through the transistors' gate-drain capacitance before the inverter switches.

## Step 2.7: Graphs inside the schematic (oscilloscope view)

Instead of ngspice's plot window, Xschem can draw the waveforms **inside the schematic**, in graph boxes like oscilloscope screens. It needs three pieces:

| Piece | What it does |
|---|---|
| `write tb_inverter.raw` in the code block | ngspice saves all results to a `.raw` file |
| `launcher.sym` ("load waves") | Ctrl+click loads that file into the graphs |
| waveform graph(s) | each box is one "screen" showing one or more signals |

**1. Save the results.** Select the code block, `Q`, and use `write` instead of `plot`:

    value=".lib /foss/pdks/sky130A/libs.tech/ngspice/sky130.lib.spice tt
    .control
    tran 10p 40n
    write tb_inverter.raw
    .endc"

(A `#` in front of a line, like `#plot v(in) v(out)`, turns it off.)

**2. Add the "load waves" button.** `Shift+I` → `devices` → `launcher.sym`. Place it, `Q`, set:

    name=h1
    descr="load waves"
    tclcommand="xschem raw_read $netlist_dir/tb_inverter.raw tran"

What it does: `descr` is the text next to the arrow. `tclcommand` runs on Ctrl+click: it reads the transient (`tran`) results from `tb_inverter.raw` in the simulation folder (`$netlist_dir`, where ngspice runs).

**3. Add a graph.** Menu **Simulation → Graphs → Add waveform graph**, click to place. Add a second one if you want separate screens.

**4. Run.** `Ctrl+S` → **Netlist** → **Simulate**. When ngspice is done, type `quit` in its terminal.

You should see: `binary raw file "tb_inverter.raw"` in the terminal, and an empty graph box in the schematic.

![ngspice terminal showing binary raw file tb_inverter.raw; launcher and empty graph in the schematic]({{ '/assets/img/inverter/2-7-raw-written.png' | relative_url }})

{: .fail }
Ran into the **Global schematic property** ("Text input") window? That is the testbench's own settings, opened by double-clicking empty background. **Cancel** it. Never use its **Load** button to open the `.raw` file: that pastes the binary file into your schematic. If you already pressed OK, do **not** save: **File → Reload** (`Alt+S`) restores the file from disk.

## Step 2.8: Choose the signals and load the waves

1. Click once on the graph's **border** (thin frame) to select it, then press `Q`.
   You should see: a property window starting with `flags=graph`.
2. Change three lines:

       x2=40e-9
       node="in
       out"
       color="4 6"

   | Line | What it does |
   |---|---|
   | `x2=40e-9` | x-axis ends at 40 ns (the length of `tran 10p 40n`) instead of 10 µs |
   | `node="in` / `out"` | the signals to draw, one per line: both in this graph (**merged**) |
   | `color="4 6"` | one color number per signal, same order |

3. **OK**, then **Ctrl+click** the green **load waves** arrow, then `Ctrl+S`.

You should see: `in` and `out` in one graph, each switching between 0 and 1.8 V, always opposite.

![Built-in Xschem graph with in and out merged, 0 to 40 ns]({{ '/assets/img/inverter/2-8-graph-merged.png' | relative_url }})

Mouse in the graph: left-drag pans, right-drag in X zooms, `F` zooms to fit all data.

{: .fail }
Double-click inside the graph opens nothing, or the wrong window? The graph settings dialog only opens on a double-click in the middle of the graph **after the waves are loaded**. Selecting the border and pressing `Q` (above) always works.

## Step 2.9 (optional): Stacked lanes (digital mode)

Each signal in its own lane, in one graph, like a logic analyzer. Select the graph border, `Q`, set:

    digital=1
    ypos1=0
    ypos2=1
    node="in
    \"-; 0.9 \"
    out"
    color="4 9 6"

| Line | What it does |
|---|---|
| `digital=1` | lanes instead of overlaid traces |
| `ypos1` / `ypos2` | how much of the lane stack is visible: raise `ypos2` if the top lane is cut off, lower it if lanes are tiny |
| `\"-; 0.9 \"` | a white divider line (color 9) between the signals |
| one `color` per `node` line | in the same order |

{: .why }
Digital mode shows **no voltage values**, only lane names and high/low. For voltages keep `digital=0` (Step 2.8), or put each signal in its own graph (add a second graph, `node="in"` in one and `node="out"` in the other).

{: .fail }
A signal is missing? Each signal (and the divider) must be on **its own line** inside `node="…"`, and there must be as many colors as lines.

## Next

[3. Layout](layout.html): draw the inverter's transistors and wires in Magic.
