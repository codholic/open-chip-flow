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

## Next

Step 2.3 (sources, ground, load) comes after I do it.
