/**
* tx_clk.v v0.00
*
* @Author  João Miguel Fernandes Magalhães
* @Contact up201305379@fe.up.pt
* @Date    sáb 03 mar 2018 17:28:50 WET
*
* This part of code is written in Verilog hardware description language (HDL).
* Please visit http://en.wikipedia.org/wiki/Verilog (or some better source)
* for more details on the language used herein.
**/


/**
* GENERAL DESCRIPTION:
*
* -Generates a clock signal
**/


module tx_clk (
  output reg clk
  );

  initial begin
    clk <= 0;
  end

  always
    #20 clk = !clk;

endmodule


/******************************************************************************\
*                                                                              *
*              @Copyright (C) 2018, #1Nadal, All Rights Reserved               *
*                                                                              *
\******************************************************************************/