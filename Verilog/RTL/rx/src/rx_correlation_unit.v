/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
* rx_filter.v v0.00                                                           *
*                                                                             *
* @Author  Joao Miguel Fernandes Magalhaes                                    *
* @Contact up201305379@fe.up.fe                                               *
* @Date    08/03/2018 17:17:01 GMT                                            *
*                                                                             *
* This part of code is written in Verilog hardware description language (HDL).*
* Please visit http://en.wikipedia.org/wiki/Verilog (or some proper source)   *
* for more details on the language used herein.                               *
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


/**
 * GENERAL DESCRIPTION:
 *
 *
 * CONSTRAINTS:
 *
 */

module rx_correlation_unit(
  input  wire               crx_clk         ,  //clock signal
  input  wire               rrx_rst         ,  //reset signal
  input  wire               erx_en          ,  //enable signal
  
  input  wire               inew_sample_trig,  //new sample triger

  input wire signed [15:0] idata_sample_0   ,
  input wire signed [15:0] idata_sample_1   ,
  input wire signed [15:0] idata_sample_2   ,
  input wire signed [15:0] idata_sample_3   ,
  input wire signed [15:0] idata_sample_4   ,
  input wire signed [15:0] idata_sample_5   ,
  input wire signed [15:0] idata_sample_6   ,
  input wire signed [15:0] idata_sample_7   ,
  input wire signed [15:0] idata_sample_8   ,
  input wire signed [15:0] idata_sample_9   ,
  input wire signed [15:0] idata_sample_10  ,
  input wire signed [15:0] idata_sample_11  ,
  input wire signed [15:0] idata_sample_12  ,
  input wire signed [15:0] idata_sample_13  ,
  input wire signed [15:0] idata_sample_14  ,
  input wire signed [15:0] idata_sample_15  ,
  input wire signed [15:0] idata_sample_16  ,
  input wire signed [15:0] idata_sample_17  ,
  input wire signed [15:0] idata_sample_18  ,
  input wire signed [15:0] idata_sample_19  ,

  input wire        [4:0]  iorder_pointer
  );

  parameter MAP_D = 0;
  parameter MAP_C = 1;
  parameter MAP_B = 2;
  parameter MAP_A = 3;

  integer i;
  
  reg signed [16:0] rresult      [19:0];
  reg        [15:0] wmultiplexer [19:0];

  wire [4:0] worder_pointer_normalized;

  //normaliizes the order pointer, becomes a number between 0 and 9
  assign worder_pointer_normalized = iorder_pointer < 10 ? iorder_pointer : iorder_pointer - 10;

  initial begin
    for (i = 0; i < 20; i = i + 1) begin
      result[i] = 0;
    end
  end

  //sample 0
  always @(*) begin
    if ((!=iorder_pointer[MAP_D] && iorder_pointer[MAP_A]) || (iorder_pointer[MAP_B] && iorder_pointer[MAP_C])) begin
      wmultiplexer[0] = - 1;
    end else begin
      if ((iorder_pointer[MAP_C] && !=iorder_pointer[MAP_A]) || (!=iorder_pointer[MAP_A] && !=iorder_pointer[MAP_B] && iorder_pointer[MAP_B])) begin
        wmultiplexer[0] = 1;
      end else begin
        wmultiplexer = 0;
      end
    end
  end

endmodule 


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
*                                                                             *
*              @Copyright (C) 2018, #1Nadal, All Rights Reserved              *
*                                                                             *
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */