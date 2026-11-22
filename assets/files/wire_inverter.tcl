# wire_inverter.tcl : wiring, labels and ports for the sky130 inverter
# Written and tested with Claude (AI assistant): coordinates computed from the transistor .mag files.
# Run inside Magic's tkcon:  source /foss/designs/inverter/mag/wire_inverter.tcl
# Assumes NMOS at (0.82, 1.275) um and PMOS at (0.82, 6.36) um (Step 3.3).

flush inverter          ;# forget unsaved hand-drawn changes, reload from disk
units microns

# in: metal1 from the NMOS gate contact (top) to the PMOS gate contact (bottom)
box 0.675um 2.165um 0.965um 4.925um
paint metal1
# enlarge the two unused gate contacts (metal1 minimum area, met1.6)
box 0.675um 0.300um 0.965um 0.615um
paint metal1
box 0.675um 7.565um 0.965um 7.880um
paint metal1

# out: both drains (right side) joined by a vertical metal1 wire
box 0.925um 1.500um 1.590um 1.775um
paint metal1
box 0.925um 5.360um 1.590um 5.650um
paint metal1
box 1.300um 1.500um 1.590um 5.650um
paint metal1

# sources tied to their guard ring (= body) with local interconnect
box -0.055um 1.175um 0.685um 1.375um
paint locali
box -0.055um 6.260um 0.685um 6.460um
paint locali

# labels + ports (pins for LVS)
box 0.820um 3.500um 0.820um 3.500um
label in c metal1
port make
box 1.445um 3.500um 1.445um 3.500um
label out c metal1
port make
box 0.04um 6.360um 0.04um 6.360um
label VDD c locali
port make
box 0.04um 1.275um 0.04um 1.275um
label GND c locali
port make

select clear
writeall force
puts "wire_inverter.tcl done: press y in the layout window for DRC"
