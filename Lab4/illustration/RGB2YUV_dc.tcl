#Specify Design Libraries
set search_path "/cad/CBDK/CBDK_TSMC90GUTM_Arm_f1.0/CIC/SynopsysDC/db/ $search_path"
set target_library "slow.db fast.db typical.db"
set link_library "* $target_library dw_foundation.sldb"
set symbol_library "tsmc090.sdb generic.sdb"
set synthetic_library "dw_foundation.sldb"
#Set Period
set clk_per 10.0
#Read File
read_file -format verilog ./RGB2YUV.v
read_file -format verilog ./Controller.v
read_file -format verilog ./Datapath.v
read_file -format verilog ./Add.v
read_file -format verilog ./Multipliper.v
read_file -format verilog ./MUX2.v
read_file -format verilog ./MUX3.v
read_file -format verilog ./MUX4.v
read_file -format verilog ./Register.v
read_file -format verilog ./ROM.v
#Change Hierarchy
current_design RGB2YUV
#Set Operating Conditions
set_operating_conditions -min_library fast -min fast -max_library slow -max slow
#Set Wire Load Model
set_wire_load_model -name tsmc090_wl10 -library slow
#Set Area Constraints
set_max_area 0
#Set Timing Constraints(Sequential circuit)
set wave [list 0 [expr $clk_per/2]]
create_clock -name "clk" -period $clk_per -waveform $wave [get_ports clk]
set_dont_touch_network  [get_clocks clk]
set_fix_hold  [get_clocks clk]
#Set Input / Output Delay
set_input_delay 0 -clock [get_clocks clk] [all_inputs]
set_output_delay 0 -clock [get_clocks clk] [all_outputs]
#Verify
check_design
check_timing
#Compile
compile -exact_map
#Report Area
report_area > ./area_report.txt
#Report Timing
report_timing -path full -delay max -max_path 1 -nworst 1 > ./timing_report.txt
#Report Power
report_power > ./power_report.txt
#Save Output File
write -hierarchy -format ddc -output ./RGB2YUV_V1_syn.ddc
write -format verilog -hierarchy -output ./RGB2YUV_V1_syn.v
write_sdf -version 2.1 -context verilog ./RGB2YUV_V1_syn.sdf
write_sdc ./RGB2YUV_V1_syn.sdc
exit
