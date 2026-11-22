---
title: 4. DRC
parent: Inverter flow
nav_order: 4
---

# 4. DRC (design rule check)

DRC checks that every shape follows the foundry's manufacturing rules: minimum width, spacing, area, enclosure… If a rule is broken, the chip may not be made correctly.
Magic checks DRC **live** while you draw, using the sky130 rules loaded from the PDK.

## Step 4.1: Read the counter

The box at the top of the layout window shows **`DRC=N`**: the number of errors. White dotted patches in the layout mark where they are.

You should see: **`DRC=0`** for the finished inverter.

![Wired inverter with DRC=0]({{ '/assets/img/inverter/3-4-wired-drc0.png' | relative_url }})

## Step 4.2: See why

Mouse over the layout window and press **`y`** (= `drc check; drc why`). Or in tkcon:

    select top cell
    drc check
    drc why

| Command | What it does |
|---|---|
| `select top cell` | selects the whole layout, so `drc why` looks everywhere |
| `drc check` | re-checks the area (normally DRC runs in the background) |
| `drc why` | prints each broken rule, with its sky130 rule name |
| `drc count total` | number of errors |
| `=` key | jump to the next error and zoom in on it |

You should see: `No errors found.`

{: .why }
The counter can lag behind while Magic is still checking. `drc catchup` waits until the check is finished.

## Errors I met on the inverter

| Message | Rule | Meaning | Fix |
|---|---|---|---|
| `Metal1 minimum area < 0.083um^2 (met1.6)` | met1.6 | a metal1 piece is too small | normal on unwired transistors (tiny contact squares); goes away once wires connect them, or paint a bit more metal1 |
| `Metal1 spacing < 0.14 (met1.2)` | met1.2 | two metal1 shapes closer than 0.14 µm | move them apart, or merge them if they are the same net |
| `Metal1 width < 0.14 (met1.1)` | met1.1 | a metal1 wire thinner than 0.14 µm | make it at least 0.14 µm wide |

Full rule list: [SkyWater sky130 periphery rules](https://skywater-pdk.readthedocs.io/en/main/rules/periphery.html).

{: .fail }
**DRC = 0 does not mean the circuit is right.** A metal1 band across both source/drain contacts passes DRC but shorts the transistor. That is what [LVS](lvs.html) is for.

## Next

[5. LVS](lvs.html): check that the layout is the same circuit as the schematic.
