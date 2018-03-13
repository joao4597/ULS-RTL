/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
* rx_filter_Testbench.v v0.00                                                 *
*                                                                             *
* @Author  Joao Miguel Fernandes Magalhaes                                    *
* @Contact up201305379@fe.up.fe                                               *
* @Date    06/03/2018 13:52:54 GMT                                            *
*                                                                             *
* This part of code is written in Verilog hardware description language (HDL).*
* Please visit http://en.wikipedia.org/wiki/Verilog (or some proper source)   *
* for more details on the language used herein.                               *
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


/**
* GENERAL DESCRIPTION:
*
* -Generates random input samples
* -Writes the expected result of the filtering to a filered filtered_CORRECT.txt
* -Acquires the result of the module and outputs it to filtered.txt
* -Compares the two files priviously generated to validate module
**/


`timescale 1ns / 1ps

module tx_filter_Testbench();

  //wire that interfaces with module under testing
  wire signed clk;
  wire signed [232 - 1:0] wosample;
  wire [8:0] oslected_coeff;
  wire ooutput_ready;

  //registers that interface with module under testing
  reg                    reset;
  reg                    enable;
  reg signed [16 - 1:0]  risample;
  reg risample_trig;
  reg [15:0]             rfilter_coeff;

  //auxiliar integer
  integer i;

  //Clock generator for testing
  tx_clk tx_clk_0(
    .clk(clk)
  );

  rx_filter rx_filter_0(
  .crx_clk            (clk           ),
  .rrx_rst            (reset         ),
  .erx_en             (enable        ),

  .isample            (risample      ),
  .inew_sample        (risample_trig ),
  .ifilter_coefficient(rfilter_coeff ),

  .oselect_coefficient(oslected_coeff),
  .orsample           (wosample      ),
  .osample_ready_trig (ooutput_ready )
  );

  initial begin

    @(negedge clk);
    //reset module
    reset         <= 1'b1;
    enable        <= 1'b1;
    risample      <= $signed(16'b1);
    rfilter_coeff <= $signed(-1);

    @(negedge clk);
    //disable reset and input the first sample
    reset <= 1'b0;
    risample <= $signed(16'd1);
    risample_trig <= 1;

    @(negedge clk);
    risample_trig <= 0;

    for(i = 0; i < 20; i = i + 1) begin
      for (integer j = 0; j < 200 - 1; j= j +1) begin
        @(negedge clk);
      end
      risample      <= $signed(i + 2);
      risample_trig <= 1;
      @(negedge clk);
      risample_trig <= 0;
    end

    $finish;
  end


endmodule

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
*                                                                             *
*              @Copyright (C) 2018, #1Nadal, All Rights Reserved              *
*                                                                             *
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */