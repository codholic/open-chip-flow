#!/bin/bash
# run_lvs.sh : compare the layout netlist with the schematic netlist (netgen LVS)
# Written with Claude (AI assistant). Run from the mag/ folder:  ./run_lvs.sh
# Needs: mag/inverter.spice   (Magic: extract all; ext2spice lvs; ext2spice)
#        ../lvs/inverter.spice (xschem -q -x -n -s -o ../lvs --tcl "set lvs_netlist 1" inverter.sch)

LAYOUT="inverter.spice inverter"            # file + cell name, from the layout
SCHEMATIC="../lvs/inverter.spice inverter"  # file + cell name, from the schematic
SETUP="$PDK_ROOT/$PDK/libs.tech/netgen/${PDK}_setup.tcl"   # sky130 rules for netgen
REPORT="lvs.out"                            # full report

netgen -batch lvs "$LAYOUT" "$SCHEMATIC" "$SETUP" "$REPORT"
echo "------ end of $REPORT ------"
tail -20 "$REPORT"
