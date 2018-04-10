@echo off
set xv_path=C:\\Xilinx\\Vivado\\2015.4\\bin
call %xv_path%/xsim rx_top_level_Testbench_behav -key {Behavioral:sim_1:Functional:rx_top_level_Testbench} -tclbatch rx_top_level_Testbench.tcl -view C:/Users/joao/Downloads/work/ULS-RTL/Verilog/RTL/rx/vivado_2015_4/rx_filter_simulation/tx_filter_Testbench_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
