# extract_pex.tcl : extract the inverter layout WITH parasitic capacitances
# Written with Claude (AI assistant). Run in Magic's tkcon (in mag/):
#   source /foss/designs/inverter/mag/extract_pex.tcl
# Output: mag/inverter_pex.spice with .subckt inverter_parax VDD in out GND

load inverter
extract all                       ;# find devices + connections, writes .ext files
ext2spice lvs                     ;# sky130 device names, hierarchy as subcircuits
ext2spice cthresh 0               ;# ...but now KEEP every parasitic capacitance (0 fF threshold)
ext2spice -o inverter_pex.spice   ;# write the netlist

# rename the top subcircuit so Xschem can use it next to the schematic 'inverter'
set f [open inverter_pex.spice r]; set t [read $f]; close $f
regsub {\.subckt inverter } $t {.subckt inverter_parax } t
set f [open inverter_pex.spice w]; puts -nonewline $f $t; close $f
puts "extract_pex.tcl done: wrote inverter_pex.spice (.subckt inverter_parax)"
