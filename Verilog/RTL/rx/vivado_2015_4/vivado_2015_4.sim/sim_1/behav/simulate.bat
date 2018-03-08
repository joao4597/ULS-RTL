@echo off
set xv_path=C:\\Xilinx\\Vivado\\2015.4\\bin
call %xv_path%/xsim tx_filter_Testbench_behav -key {Behavioral:sim_1:Functional:tx_filter_Testbench} -tclbatch tx_filter_Testbench.tcl -view C:/Users/joao/GoogleDrive/FEUP/Tese/dev/Verilog/RTL/rx/vivado_2015_4/rx_filter_simulation/tx_filter_Testbench_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
