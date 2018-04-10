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

module rx_correlation_unit #(
  parameter SAMPLE_POSITION = 0
  )(
  input  wire               crx_clk         ,  //clock signal
  input  wire               rrx_rst         ,  //reset signal
  input  wire               erx_en          ,  //enable signal

  input  wire               inew_sample_trig,

  input  wire signed [15:0] isample         ,
  input  wire signed [15:0] isample_plus_ten,

  output reg                obit_ready      ,
  output reg  signed [16:0] oresult_0       ,
  output reg  signed [16:0] oresult_1
  );

  reg         [3:0] rnormalized_order;
  reg signed [16:0] rsum_0, rsum_1   ;
  reg               flag             ;

  //flag used to count the two clocks necessary to process one bit
  always @(posedge crx_clk) begin
    if (rrx_rst) begin
      flag <= 0;
    end else begin
      if (!erx_en) begin
        flag <= 0;
      end else begin
        if (inew_sample_trig) begin
          flag <= 0;
        end else begin
          flag <= flag + 1;
        end
      end
    end
  end

  //based on the sample order it decides what to do with the samples
  always @(*) begin
    if (rnormalized_order > 1 && rnormalized_order < 5) begin
      rsum_0 = oresult_0 - isample         ;
      rsum_1 = oresult_1 - isample_plus_ten;
    end else begin
      if (rnormalized_order > 6) begin
        rsum_0 = oresult_0 + isample         ;
        rsum_1 = oresult_1 + isample_plus_ten;
      end else begin
        rsum_0 = 0;
        rsum_1 = 0;
      end
    end
  end

  //Keeps track of the samples order relative to its position
  always @(posedge crx_clk) begin
    if (rrx_rst == 1) begin
      rnormalized_order <= 0 + SAMPLE_POSITION;
    end else begin
      if (inew_sample_trig) begin
        if (rnormalized_order >= 9) begin
          rnormalized_order <= 0;
        end else begin
          rnormalized_order <= rnormalized_order + 1;
        end
      end
    end
  end

  //holds the result of the correlation of each sample for the
  //two clocks corresponding to one bit of the pseudo random binary
  //sequence
  always @(posedge crx_clk) begin
    if (rrx_rst) begin
      oresult_0  <= 0;
      oresult_1  <= 0;
      obit_ready <= 0;
    end else begin
      if (!erx_en) begin
        oresult_0  <= 0;
        oresult_1  <= 0;
        obit_ready <= 0;
      end else begin
        if (!flag) begin
          oresult_0  <= isample;
          oresult_1  <= isample_plus_ten;
          obit_ready <= 0;
        end else begin
          oresult_0  <= rsum_0;
          oresult_1  <= rsum_1;
          obit_ready <= 1;
        end
      end
    end
  end

endmodule


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
*                                                                             *
*              @Copyright (C) 2018, #1Nadal, All Rights Reserved              *
*                                                                             *
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
