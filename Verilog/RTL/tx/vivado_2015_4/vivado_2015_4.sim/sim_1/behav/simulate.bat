@echo off
set xv_path=C:\\Xilinx\\Vivado\\2015.4\\bin
call %xv_path%/xsim tx_modulator_Testbench_behav -key {Behavioral:sim_1:Functional:tx_modulator_Testbench} -tclbatch tx_modulator_Testbench.tcl -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
