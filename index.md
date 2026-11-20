---
title: Home
nav_order: 1
---

# Chip Design with Open Source Resources

My notes for designing a chip with **free, open-source tools**, written step by step as I do it.
No Claude, no ChatGPT needed to follow along: just copy each command.

## The flow

| # | Step | Tool |
|---|------|------|
| 0 | [Set up the tools](setup/) | Docker + IIC-OSIC-TOOLS |
| 1 | [Inverter schematic](inverter/schematic.html) | Xschem |
| 2 | [Simulation](inverter/simulation.html) | ngspice |
| 3 | [Layout](inverter/layout.html) | Magic |
| 4 | [DRC](inverter/drc.html) | Magic |
| 5 | [LVS](inverter/lvs.html) | netgen |
| 6 | [Post-layout simulation](inverter/pex.html) | Magic + ngspice |

Then: a SAR ADC with the same flow.

## How each step is written

    Step N: what to do
        command to copy
    What it does: one line
    You should see: what success looks like
    If it fails: the fix

## Tested with

| | Version |
|---|---|
| Computer | MacBook, Apple silicon (arm64), macOS 26 |
| IIC-OSIC-TOOLS | 2026.10 |
| Xschem | 3.4.8RC |
| ngspice | 47 |
| Magic | 8.3.685 |
| netgen | 1.5.324 |
| PDK | sky130A |

## Credits

The tools are [IIC-OSIC-TOOLS](https://github.com/iic-jku/iic-osic-tools) (JKU Linz).
Course I learned from: [Zero to ASIC Analog](https://www.zerotoasiccourse.com/).
For theory: [The Art of Analog IC Design](https://www.skillsurf.org/art_of_aicd/) (SkillSurf).
