/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
* rx_filter.v v0.00                                                           *
*                                                                             *
* @Author  Joao Miguel Fernandes Magalhaes                                    *
* @Contact up201305379@fe.up.fe                                               *
* @Date    seg 02 abr 2018 21:49:26 WEST BST                                  *
*                                                                             *
* This part of code is written in Verilog hardware description language (HDL).*
* Please visit http://en.wikipedia.org/wiki/Verilog (or some proper source)   *
* for more details on the language used herein.                               *
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


/**
 * GENERAL DESCRIPTION:
 *
 * -Receives a new sample every 512 clocks signaled by a trigger
 * -Stores the samples in a round robin fashion
 * -Holds the last 510 samples at all times
 * -Every time a inew_sample trigger is received it starts outputting the 510 stored samples
 *   from oldest to most recent
 * -Only stores a new sample when a wr_en_RAM is received, a inew_sample_trig means that a new sample arrived
 *   however, it can be stored in on of the other parallel RAM blocks
 *
 *
 * CONSTRAINTS:
 *
 *
 */

module rx_BRAM_internal_controller #(
    parameter MEMORY_LENGTH = 510
  )
  (
    input  wire               crx_clk         ,
    input  wire               rrx_rst         ,
    input  wire               erx_en          ,

    input  wire               new_sample_trig ,
    input  wire               wr_en_RAM       ,
    input  wire signed [15:0] data_in_RAM     ,

    output wire signed [15:0] data_out_RAM
  );


  reg [8:0] rrd_addr_RAM;
  reg [8:0] rwr_addr_RAM;

  reg [10:0] roldest_sample_addr;


  //Simple dual-port BRAM
  rx_BRAM_16_510_filtered_samples rx_BRAM_16_510_filtered_samples_0(crx_clk, rrx_rst, 1'b1, 1'b1, wr_en_RAM , rwr_addr_RAM, rrd_addr_RAM, data_in_RAM, data_out_RAM);


  //Updates the next address to write to every time a write enable is received
  always @(posedge crx_clk) begin
    if (rrx_rst == 1) begin
      rwr_addr_RAM <= 0;
    end else begin
      if (wr_en_RAM) begin
        if (rwr_addr_RAM == MEMORY_LENGTH - 1) begin
          rwr_addr_RAM <= 0;
        end else begin
          rwr_addr_RAM <= rwr_addr_RAM + 1;
        end
      end
    end
  end

  //Updates the next address to be read every clock
  always @(posedge crx_clk) begin
    if (rrx_rst == 1) begin
      rrd_addr_RAM <= 0;
    end else begin
      if (wr_en_RAM) begin
        rrd_addr_RAM <= rwr_addr_RAM + 1;
      end else begin
        if (new_sample_trig) begin
          rrd_addr_RAM <= rwr_addr_RAM;
        end else begin
          if (rrd_addr_RAM < MEMORY_LENGTH - 1) begin
            rrd_addr_RAM <= rrd_addr_RAM + 1;
          end else begin
            rrd_addr_RAM <= 0;
          end
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
