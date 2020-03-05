# 
# Synthesis run script generated by Vivado
# 

set_param xicom.use_bs_reader 1
set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
create_project -in_memory -part xc7a35tcpg236-1

set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir /home/grantlg2/Code/CS_296_41/fpga_accelerator/fpga_accelerator.cache/wt [current_project]
set_property parent.project_path /home/grantlg2/Code/CS_296_41/fpga_accelerator/fpga_accelerator.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property board_part digilentinc.com:basys3:part0:1.1 [current_project]
set_property vhdl_version vhdl_2k [current_fileset]
read_verilog -library xil_defaultlib {
  /home/grantlg2/Code/CS_296_41/fpga_accelerator/fpga_accelerator.srcs/sources_1/new/uart.v
  /home/grantlg2/Code/CS_296_41/fpga_accelerator/fpga_accelerator.srcs/sources_1/new/top_level.v
}
read_xdc /home/grantlg2/Code/CS_296_41/fpga_accelerator/fpga_accelerator.srcs/constrs_1/imports/src/Basys3_Master.xdc
set_property used_in_implementation false [get_files /home/grantlg2/Code/CS_296_41/fpga_accelerator/fpga_accelerator.srcs/constrs_1/imports/src/Basys3_Master.xdc]

synth_design -top top_level -part xc7a35tcpg236-1
write_checkpoint -noxdef top_level.dcp
catch { report_utilization -file top_level_utilization_synth.rpt -pb top_level_utilization_synth.pb }