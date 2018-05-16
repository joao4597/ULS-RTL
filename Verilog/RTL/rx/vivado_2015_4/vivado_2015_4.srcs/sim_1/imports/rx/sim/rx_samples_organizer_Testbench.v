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
* 
* 
* 
* 
**/


`timescale 1ns / 1ps

module rx_samples_organizer_Testbench();

  wire signed clk;
  //Clock generator for testing
  tx_clk tx_clk_0(
    .clk(clk)
  );

  integer i;
  integer j;

  reg enable;
  reg reset;
  reg triger;

  reg signed [15:0] rsample_in;

  wire signed [15:0] wsample_out [19:0];


  rx_samples_organizer rx_samples_organizer_0(
  .crx_clk         (clk            ),
  .rrx_rst         (reset          ),
  .erx_en          (enable         ),
  .idata_in_RAM    (rsample_in     ),
       
  .inew_sample_trig(triger         ),
   
  .odata_0         (wsample_out[0] ),
  .odata_1         (wsample_out[1] ),
  .odata_2         (wsample_out[2] ),
  .odata_3         (wsample_out[3] ),
  .odata_4         (wsample_out[4] ),
  .odata_5         (wsample_out[5] ),
  .odata_6         (wsample_out[6] ),
  .odata_7         (wsample_out[7] ),
  .odata_8         (wsample_out[8] ),
  .odata_9         (wsample_out[9] ),
  .odata_10        (wsample_out[10]),
  .odata_11        (wsample_out[11]),
  .odata_12        (wsample_out[12]),
  .odata_13        (wsample_out[13]),
  .odata_14        (wsample_out[14]),
  .odata_15        (wsample_out[15]),
  .odata_16        (wsample_out[16]),
  .odata_17        (wsample_out[17]),
  .odata_18        (wsample_out[18]),
  .odata_19        (wsample_out[19])
  );

  initial begin

    @(negedge clk);
    //reset module
    reset         <= 1'b1;
    enable        <= 1'b1;
    i              = 0   ;
    rsample_in    <= $signed(i);

    @(negedge clk);
    //disable reset and input the first sample
    reset    <= 1'b0;

    for(i = 0; i < 10200; i = i + 1) begin
      rsample_in <= $signed(i);
      triger <= 1;
      @(negedge clk);
      triger <= 0;
      
      for(j = 0; j < 512; j = j + 1) begin
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