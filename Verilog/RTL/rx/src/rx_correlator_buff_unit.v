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
 * -This module has access to a memory shared with three other modules
 * -Stores 128 samples surrounding the correlation peak
 * -256 lines in the sahred ram are available to this module, starting at RAM_BASE_ADDRESS
 * -The 256 addresses are used as two 128 lines buffer, one stores the incoming samples
 * the other holds the maximum known up to each point, they alternate roles every time a new maximum
 * is received
 *
 * CONSTRAINTS:
 *
 *
 */

module rx_correlator_buff_unit#(
    parameter RAM_BASE_ADDRESS = 0                   //the RAM  on which the samples are to be stored are shared
                                                     //by 3 other modules like this one, this parametter sets the base 
                                                     //address from which present module may start filling the buffers
  )(  
  input  wire               crx_clk               ,  //clock signal
  input  wire               rrx_rst               ,  //reset signal
  input  wire               erx_en                ,  //enable signal
  
  input wire                inew_samle_trigger    ,  //new correlation result trigger

  input  wire signed [31:0] isample_correlation   ,  //received result from correlator
 
  output wire               oram_w_eanble         ,  //shared memory write enable
  output wire        [9:0]  oram_w_address        ,  //shared memory write address

  output wire signed [31:0] oram_data_in          ,  //sample to be written in shared memory
  output reg                r_buff_flag              //buffer currently being used to store samples
  );

  reg signed [31:0] rmax    ;

  reg [6:0] rwrite_address  ;

  reg [6:0] rsamples_missing;


  //assign received sample to the output so it can be written in the shared memory
  assign oram_data_in = isample_correlation;


  //shared memory write address for the received sample
  //writes to one of two buffers depending on r_buff_flag
  assign oram_w_address = r_buff_flag ? (rwrite_address + RAM_BASE_ADDRESS + 128 ):  rwrite_address + RAM_BASE_ADDRESS;

  
  always @(posedge crx_clk) begin
    if (rrx_rst) begin
      rmax     <= 0;            //holds the value of the max upt to each point in time
      rsamples_missing <= 127;  //after a new peak if received the present buffer still needs to store 64 samples
      r_buff_flag <= 0;         //signals wich buffer is being used to store the samples inreal time
    end else begin
      if (!erx_en) begin        //the block is desable in order to read buffers after a signal is received
        //rmax     <= 0;
        //rsamples_missing <= 127;
        //r_buff_flag <= 0;
      end else begin
        if (inew_samle_trigger) begin
          if (isample_correlation > rmax) begin
            rmax     <= isample_correlation;
            rsamples_missing <= 64;              //after a new max is received 64 samples must yet be stored
          end else begin
            if (rsamples_missing == 1) begin
              r_buff_flag <= r_buff_flag + 1;    //switch buffers when 128 samples surrounding the max are stored
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
  end

  //increment write address each time a new sample is received
  always @(posedge crx_clk) begin
    if (rrx_rst) begin
      rwrite_address <= 0;
    end else begin
      if (!erx_en) begin
        //rwrite_address <= 0;
      end else begin
        if (inew_samle_trigger) begin
          rwrite_address <= rwrite_address + 1;
        end
      end
    end
  end

  assign oram_w_eanble = inew_samle_trigger;

  endmodule


  /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
*                                                                             *
*              @Copyright (C) 2018, #1Nadal, All Rights Reserved              *
*                                                                             *
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */