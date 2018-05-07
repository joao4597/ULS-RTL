/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
* rx_peak_identification.v v0.00                                              *
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

module rx_correlator_buff_unit#(
    parameter RAM_BASE_ADDRESS = 0
  )(  
  input  wire               crx_clk               ,  //clock signal
  input  wire               rrx_rst               ,  //reset signal
  input  wire               erx_en                ,  //enable signal
  
  input wire                inew_samle_trigger    ,

  //rx_correlator result of on of the 16 sequences
  input  wire signed [32:0] isample_correlation   ,

  //Interface with BRAM shared with 3 other rx_correlator_buff_unit
  input  wire signed [31:0] iram_data_out         ,
  
  output wire               oram_r_enable         ,  
  output wire               oram_w_eanble         , 
  output wire        [9:0]  oram_w_address        , 
  output reg         [9:0]  oram_r_address        ,

  output wire signed [31:0] oram_data_in          ,   
  )

  reg signed [31:0] rmax    ;
  reg signed [6:0]  rmax_pos;

  reg rread_addres     [6:0];
  reg rwrite_address   [6:0];

  reg rsamples_missing [6:0];

  reg r_buff_flag;


  assign oram_w_address = r_buff_flag ? rwrite_address + RAM_BASE_ADDRESS + 128 : rwrite_address + RAM_BASE_ADDRESS      ;
  assign oram_r_address = r_buff_flag ? rread_addres   + RAM_BASE_ADDRESS       : rread_addres   + RAM_BASE_ADDRESS + 128;


  //keep track of correlation peak
  always @(posedge crx_clk) begin
    if (rrx_rst) begin
      rmax     <= 0;
      rmax_pos <= 0;
      rsamples_missing <= 127;
    end else begin
      if (!erx_en) begin
        rmax     <= 0;
        rmax_pos <= 0;
        rsamples_missing <= 127;
      end else begin
        if (inew_samle_trigger) begin
          if (isample_correlation > rmax) begin
            rmax     <= isample_correlation;
            rmax_pos <= rwrite_address     ;
            rsamples_missing <= 64;
          end
        end
      end
    end
  end

  //keep track of correlation peak
  always @(posedge crx_clk) begin
    if (rrx_rst) begin
      r_buff_flag <= 0;
    end else begin
      if (!erx_en) begin
        r_buff_flag <= 0;
      end else begin
        if (inew_samle_trigger) begin
          if (rsamples_missing == 1) begin
            r_buff_flag <= r_buff_flag + 1;
            rsamples_missing <= 127;
          end else begin
            if (rsamples_missing < 65) begin
              rsamples_missing <= rsamples_missing - 1;
            end
          end
        end
      end
    end
  end

  endmodule