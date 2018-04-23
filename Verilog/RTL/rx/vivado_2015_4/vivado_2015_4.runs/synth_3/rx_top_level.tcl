# 
# Synthesis run script generated by Vivado
# 

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
create_project -in_memory -part xc7z010clg400-1

set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir C:/Users/joao/Downloads/work/ULS-RTL/Verilog/RTL/rx/vivado_2015_4/vivado_2015_4.cache/wt [current_project]
set_property parent.project_path C:/Users/joao/Downloads/work/ULS-RTL/Verilog/RTL/rx/vivado_2015_4/vivado_2015_4.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property vhdl_version vhdl_2k [current_fileset]
read_verilog -library xil_defaultlib {
  C:/Users/joao/Downloads/work/ULS-RTL/Verilog/RTL/rx/src/rx_BRAM_16_256_binary_sequences.v
  C:/Users/joao/Downloads/work/ULS-RTL/Verilog/RTL/rx/src/rx_BRAM_16_510_filtered_samples.v
  C:/Users/joao/Downloads/work/ULS-RTL/Verilog/RTL/rx/src/rx_sequnces_bits_feader.v
  C:/Users/joao/Downloads/work/ULS-RTL/Verilog/RTL/rx/src/rx_correlation_unit.v
  C:/Users/joao/Downloads/work/ULS-RTL/Verilog/RTL/rx/src/rx_BRAM_16_128_low_pass.v
  C:/Users/joao/Downloads/work/ULS-RTL/Verilog/RTL/rx/src/rx_BRAM_16_128.v
  C:/Users/joao/Downloads/work/ULS-RTL/Verilog/RTL/rx/src/rx_BRAM_internal_controller.v
  C:/Users/joao/Downloads/work/ULS-RTL/Verilog/RTL/rx/src/rx_BRAM_16_512_band_pass.v
  C:/Users/joao/Downloads/work/ULS-RTL/Verilog/RTL/rx/src/rx_BRAM_16_512.v
  C:/Users/joao/Downloads/work/ULS-RTL/Verilog/RTL/rx/src/rx_correlator.v
  C:/Users/joao/Downloads/work/ULS-RTL/Verilog/RTL/rx/src/rx_low_pass_filter.v
  C:/Users/joao/Downloads/work/ULS-RTL/Verilog/RTL/rx/src/rx_samples_organizer.v
  C:/Users/joao/Downloads/work/ULS-RTL/Verilog/RTL/rx/src/rx_band_pass_filter.v
  C:/Users/joao/Downloads/work/ULS-RTL/Verilog/RTL/rx/src/rx_peak_identification.v
  C:/Users/joao/Downloads/work/ULS-RTL/Verilog/RTL/rx/src/rx_top_level.v
}
read_xdc C:/Users/joao/Downloads/work/ULS-RTL/Verilog/RTL/rx/vivado_2015_4/vivado_2015_4.srcs/constrs_1/new/teste_rx.xdc
set_property used_in_implementation false [get_files C:/Users/joao/Downloads/work/ULS-RTL/Verilog/RTL/rx/vivado_2015_4/vivado_2015_4.srcs/constrs_1/new/teste_rx.xdc]

synth_design -top rx_top_level -part xc7z010clg400-1 -fanout_limit 400 -fsm_extraction one_hot -keep_equivalent_registers -resource_sharing off -no_lc -shreg_min_size 5
write_checkpoint -noxdef rx_top_level.dcp
catch { report_utilization -file rx_top_level_utilization_synth.rpt -pb rx_top_level_utilization_synth.pb }
