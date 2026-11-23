---
title: Design of Analog CMOS IC notes
nav_order: 5
has_children: true
---

# Design of Analog CMOS IC notes

My reading notes for **B. Razavi, *Design of Analog CMOS Integrated Circuits*, 2nd ed. (McGraw-Hill, 2017)**.
For each chapter: the ideas in my own words, the key equations, and then the circuits **built and simulated with the
open-source flow on this site** (Xschem + ngspice, sky130), so the hand analysis is checked against a real simulation.

These are my notes, not a copy of the book: get the book to follow along.

## Chapters

| Ch. | Topic | Notes | Built in sky130 |
|---|---|---|---|
| 1 | Introduction to Analog Design | not started | |
| 2 | Basic MOS Device Physics | not started | |
| 3 | Single-Stage Amplifiers | not started | |
| 4 | Differential Amplifiers | not started | |
| 5 | Current Mirrors and Biasing Techniques | not started | |
| 6 | Frequency Response of Amplifiers | not started | |
| 7 | Noise | not started | |
| 8 | Feedback | not started | |
| 9 | Operational Amplifiers | not started | |
| 10 | Stability and Frequency Compensation | not started | |
| 11 | Nanometer Design Studies | not started | |
| 12 | Bandgap References | not started | |
| 13 | Introduction to Switched-Capacitor Circuits | not started | |
| 14 | Nonlinearity and Mismatch | not started | |
| 15 | Oscillators | not started | |
| 16 | Phase-Locked Loops | not started | |
| 17 | Short-Channel Effects and Device Models | not started | |
| 18 | CMOS Processing Technology | not started | |
| 19 | Layout and Packaging | not started | |

## How each chapter page is laid out

1. **Big picture**: what problem the chapter solves, in a few lines.
2. **Key ideas**: short notes, in my own words.
3. **Key equations**: the ones I actually use, with what each symbol means.
4. **Build it**: the circuit in Xschem + ngspice (sky130): schematic, testbench, what to measure.
5. **Hand vs. simulation**: a small table comparing my hand calculation with ngspice, and why they differ.
6. **Handwritten notes**: scans of my paper derivations, when I have them.
7. **Questions / to revisit**.
