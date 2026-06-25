# Specify Design Libraries
set search_path "/cad/CBDK/CBDK_TSMC90GUTM_Arm_f1.0/CIC/SynopsysDC/db/ $search_path"
set target_library "slow.db fast.db typical.db"
set link_library "* $target_library dw_foundation.sldb"
set symbol_library "tsmc090.sdb generic.sdb"
set synthetic_library "dw_foundation.sldb"

# Clock period
set clk_per 10.0

# Read synthesizable RTL files only. Do not read the testbench.
read_file -format verilog ./RGB2YUV_V2.v
read_file -format verilog ./Controller_V2.v
read_file -format verilog ./Datapath_V2.v
read_file -format verilog ./AddSub.v
read_file -format verilog ./Multipliper.v
read_file -format verilog ./Register.v

# Set top module
current_design RGB2YUV_V2
link

# Operating conditions
set_operating_conditions -min_library fast -min fast -max_library slow -max slow
set_wire_load_model -name tsmc090_wl10 -library slow
set_max_area 0

# Timing constraints
set wave [list 0 [expr $clk_per/2]]
create_clock -name "clk" -period $clk_per -waveform $wave [get_ports clk]
set_dont_touch_network [get_clocks clk]
set_fix_hold [get_clocks clk]
set_input_delay 0 -clock [get_clocks clk] [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay 0 -clock [get_clocks clk] [all_outputs]

# Verify and synthesize
check_design
check_timing
compile -exact_map

# Reports
report_area > ./area_report_V2.txt
report_timing -path full -delay max -max_path 1 -nworst 1 > ./timing_report_V2.txt
report_power > ./power_report_V2.txt

# Output files
write -hierarchy -format ddc -output ./RGB2YUV_V2_syn.ddc
write -format verilog -hierarchy -output ./RGB2YUV_V2_syn.v
write_sdf -version 2.1 -context verilog ./RGB2YUV_V2_syn.sdf
write_sdc ./RGB2YUV_V2_syn.sdc

exit
