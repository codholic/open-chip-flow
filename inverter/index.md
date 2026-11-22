---
title: Inverter flow
nav_order: 3
has_children: true
---

# Inverter: from schematic to post-layout simulation

The simplest circuit, taken through every step of the flow.
Design folder: `/foss/designs/inverter` (`xschem/`, `mag/`, `sim/`).

| Step | Result |
|---|---|
| [1. Schematic](schematic.html) | PMOS W=2, NMOS W=1, L=0.15 |
| [2. Simulation](simulation.html) | `out` = inverted `in` |
| [3. Layout](layout.html) | Magic, wiring by script |
| [4. DRC](drc.html) | 0 errors |
| [5. LVS](lvs.html) | Circuits match uniquely |
| [6. Post-layout simulation](pex.html) | tpHL 48.8 → 51.9 ps, tpLH 57.7 → 61.5 ps |
