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
* - This block exists for the porpose of testing the rx_top_level module
* 
**/


`timescale 1ns / 1ps

module rx_top_level_Testbench();

  wire signed clk;
  wire signed [40:0] sample_out [16:0];

  reg reset, enable;
  reg signed [15:0] sample_in;
  reg               trigger;
  //Clock generator for testing
  tx_clk tx_clk_0(
    .clk(clk)
  );


  //block uder testing
  rx_top_level rx_top_level_0(
  .crx_clk               (clk           ),  //clock signal
  .rrx_rst               (reset         ),  //reset signal
  .erx_en                (enable        ),  //enable signal
       
  .inew_sample           (sample_in     ),
  .inew_sample_trig      (trigger       ),
 
  .wcorrelation_result_0 (sample_out[0] ),
  .wcorrelation_result_1 (sample_out[1] ),
  .wcorrelation_result_2 (sample_out[2] ),
  .wcorrelation_result_3 (sample_out[3] ),
  .wcorrelation_result_4 (sample_out[4] ),
  .wcorrelation_result_5 (sample_out[5] ),
  .wcorrelation_result_6 (sample_out[6] ),
  .wcorrelation_result_7 (sample_out[7] ),
  .wcorrelation_result_8 (sample_out[8] ),
  .wcorrelation_result_9 (sample_out[9] ),
  .wcorrelation_result_10(sample_out[10]),
  .wcorrelation_result_11(sample_out[11]),
  .wcorrelation_result_12(sample_out[12]),
  .wcorrelation_result_13(sample_out[13]),
  .wcorrelation_result_14(sample_out[14]),
  .wcorrelation_result_15(sample_out[15])
  );


  integer i, j;

  assign sample_out[16] = i;
  //test
  initial begin

    //reset module
    @(negedge clk);
    reset     <= 1'b1;
    enable    <= 1'b1;
    sample_in <= 1'b0;

    
    @(negedge clk);
    reset    <= 1'b0;


    for (i = 0; i < 10200; i = i + 1) begin
      sample_in <= $signed(i);
      trigger <= 1'b1;
      @(negedge clk);
      trigger <= 1'b0;

      //wait 512 clocks between new samples
      for (j = 0; j < 511; j = j + 1) begin
        @(negedge clk);
      end
    end


    $finish;
  end


endmodule

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
*                                                                             *
*              @Copyright (C) 2018, #1Nadal, All Rights Reserved              *
*                                                                             *
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */