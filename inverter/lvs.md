---
title: 5. LVS
parent: Inverter flow
nav_order: 5
---

# 5. LVS (layout vs schematic)

LVS checks that the **layout is the same circuit as the schematic**: same transistors, same sizes, same connections, same pins.
DRC only checks shapes; LVS checks the circuit. A layout can pass DRC and still be wrong (for example a short between source and drain).

{: .why }
**Done by Claude (AI assistant).** Claude worked out the commands, wrote the helper script `run_lvs.sh`, tested the whole LVS on copies of my netlists, and checked my results. I only ran the commands below in Magic and the terminal. The steps are written so you can do them without Claude.

## The idea

    layout (inverter.mag)  --Magic extract-->  mag/inverter.spice  \
                                                                    netgen  -->  match / no match
    schematic (inverter.sch) --Xschem netlist--> lvs/inverter.spice /

## Step 5.1: Extract the layout netlist (Magic)

In tkcon:

    extract all
    ext2spice lvs
    ext2spice

| Command | What it does |
|---|---|
| `extract all` | Magic finds the devices and connections in the shapes; writes one `.ext` file per cell |
| `ext2spice lvs` | sets the SPICE output for LVS: no parasitics, sky130 device names |
| `ext2spice` | writes `mag/inverter.spice` |

You should see: `exttospice finished.`

Result (`mag/inverter.spice`, shortened):

    .subckt inverter in out VDD GND
    X… GND GND out in  sky130_fd_pr__nfet_01v8_…   (B D S G)  w=1 l=0.15
    X… VDD VDD out in  sky130_fd_pr__pfet_01v8_…   (B D S G)  w=2 l=0.15
    .ends

## Step 5.2: Make the schematic netlist (Xschem, no window)

In the terminal:

    cd /foss/designs/inverter/xschem
    xschem -q -x -n -s -o /foss/designs/inverter/lvs --tcl "set lvs_netlist 1" inverter.sch

| Option | What it does |
|---|---|
| `-n -s` | make a SPICE netlist |
| `-x` | no window |
| `-q` | quit when done |
| `-o …/lvs` | write it into the `lvs/` folder |
| `--tcl "set lvs_netlist 1"` | write the inverter as `.subckt inverter …` with its pins, which is what LVS compares |

Result (`lvs/inverter.spice`):

    .subckt inverter VDD in out GND
    XM1 out in VDD VDD sky130_fd_pr__pfet_01v8 L=0.15 W=2 nf=1
    XM2 out in GND GND sky130_fd_pr__nfet_01v8 L=0.15 W=1 nf=1
    .ends

## Step 5.3: Compare with netgen

Claude put the netgen command into a script, because the full line is long and kept getting cut when typed by hand. In the terminal:

    cd /foss/designs/inverter/mag
    ./run_lvs.sh

Script: [run_lvs.sh]({{ '/assets/files/run_lvs.sh' | relative_url }}). It runs:

    netgen -batch lvs "inverter.spice inverter" "../lvs/inverter.spice inverter" \
        $PDK_ROOT/$PDK/libs.tech/netgen/sky130A_setup.tcl lvs.out

| Part | Meaning |
|---|---|
| `"inverter.spice inverter"` | layout netlist file + cell name |
| `"../lvs/inverter.spice inverter"` | schematic netlist file + cell name |
| `sky130A_setup.tcl` | sky130 rules for netgen: which devices are the same, which parameters to compare |
| `lvs.out` | the full report |

`./run_lvs.sh` = run the file `run_lvs.sh` in this folder.

You should see: both circuits with 2 devices and 4 nets, the same pins `out`, `in`, `VDD`, `GND`, and

    Final result: Circuits match uniquely.

![netgen LVS result: Circuits match uniquely, pins out in VDD GND on both sides]({{ '/assets/img/inverter/5-lvs-match.png' | relative_url }})

The `Warning: netgen command 'format' …` lines and `Call to undefined subcircuit … Creating placeholder` are normal.

{: .fail }
`wrong # args: should be "lvs name1 name2 ?setupfile? ?logfile?…"`: the two quoted parts were typed with **no space** between them (`"…inverter""../lvs/…"`), so netgen saw one argument. Put a space between them.

{: .fail }
`Error: Setup file setup.tcl does not exist.`: the setup file argument was left off. netgen then looks for a `setup.tcl` that is not there. Add `$PDK_ROOT/$PDK/libs.tech/netgen/sky130A_setup.tcl lvs.out` at the end, or use `./run_lvs.sh`.

## Next

[6. Post-layout simulation](pex.html): extract the parasitic capacitances and simulate again.
