---
title: Problems & fixes
nav_order: 10
---

# Problems & fixes

Errors I hit and how I fixed them.

| Problem | Cause | Fix |
|---|---|---|
| Xschem/Magic use IHP devices, not sky130 | Tools default to the IHP PDK | Add `.designinit` ([Setup Step 6](setup/mac.html#step-6-choose-the-sky130-pdk)) |
| "No such file" / Magic "Cannot open output file" after deleting files in Finder | Docker file-sharing cache on Mac | Change files inside the tools desktop, or stop + start the tools |
| Magic hangs at extraction on older (TT06-era) designs | Magic 8.3.685 hangs on `ext2spice -d` | Remove `-d` from `ext2spice -d -o` in the extract script |
| `make` still busy after Ctrl+C on a Magic job | Magic keeps running in the background | Close that terminal, check with `ps` that magic is gone |
| Xschem alert: `.../sky130_fd_pr/doc/pfet_01v8.svg does not seem to be an xschem file` | Symbol search also lists the documentation picture (`.svg` in `doc/`) | Click **No**; pick `pfet_01v8.sym` (ends in `.sym`, not in `doc/`) |
| Code block shows only `.lib` | `value=` text saved without quotes: Xschem keeps only the first word | Write `value="…"` with the quotes ([Step 2.4](inverter/simulation.html#step-24-add-the-simulation-commands)) |
| ngspice cannot find the models | Wrong file name, e.g. `spice.lib.spice` | Use `/foss/pdks/sky130A/libs.tech/ngspice/sky130.lib.spice tt` |
| Double-click opens "Text input" / **Global schematic property** | Double-click landed on the empty background, not the graph | **Cancel**. Select the graph border, press `Q` ([Step 2.8](inverter/simulation.html#step-28-choose-the-signals-and-load-the-waves)) |
| Binary garbage in a property window after pressing **Load** | **Load** pastes a file as text into that property; it does not load simulation results | Do not save. **File → Reload** (`Alt+S`). Load results with Ctrl+click on the **load waves** launcher |
| Magic: cursor stuck in wire mode after pressing `p` | `p` starts interactive wire tracking; Esc is not bound in this setup | Save nothing, `quit`, reopen. Avoid `p`; paint boxes instead |
| Magic: `select cell …` selects nothing, `move` does nothing | Used the file name (`….mag`) | Use the instance name (ends in `_0`); list them with `cellname list children` |
| Magic: `q` says "No gencell device is selected" | Window shows the transistor's own cell, not `inverter` | `load inverter`, click **flush**, place again |
| Magic: box corner will not land on an edge | Box snaps to a grid | `snap internal` in tkcon, or type exact `box` coordinates |
| Magic: files saved in the wrong folder | Magic saves where it was started | `pwd` / `cd` in tkcon |
| Cannot copy text into the tools desktop | Mac clipboard is not shared automatically | noVNC tab on the left edge → **Clipboard**; or put commands in a `.tcl` file and `source` it |
