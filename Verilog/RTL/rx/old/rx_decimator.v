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
 *
 */

module rx_decimator #(
  parameter DECIMATION = 4
  )(
    input  wire crx_clk          ,  //clock signal
    input  wire rrx_rst          ,  //reset signal
    input  wire erx_en           ,  //enable signal
    input  wire inew_sample_trigg,  
  
    output wire onew_sample_trigg
    );

  reg [$clog2(DECIMATION) - 1:0] rcounter;

  //Delay the enqable signal one clock
  always @(posedge crx_clk) begin
    if (rrx_rst) begin
      rcounter <= 0;
    end else begin
      if (!erx_en) begin
        rcounter <= 0;
      end else begin
        if (inew_sample_trig) begin
          rcounter <= rcounter + 1;
        end
      end
    end
  end

  assign onew_sample_trigg = rcounter == 0 ? inew_sample_trig : 1'b0;

endmodule


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
*                                                                             *
*              @Copyright (C) 2018, #1Nadal, All Rights Reserved              *
*                                                                             *
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
