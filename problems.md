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
