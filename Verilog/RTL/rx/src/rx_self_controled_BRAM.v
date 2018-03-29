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

module rx_self_controled_BRAM #(
    parameter MEMORY_INDEX = 0,
    parameter MEMORY_LENGTH = 510
  )
  (
    input         wire        crx_clk         ,
    input         wire        rrx_rst         ,
    input         wire        erx_en          ,
    input         wire        inew_sample_trig,
   
    input         wire        rd_en_RAM       ,
    input         wire        wr_en_RAM       ,
    input  signed wire [15:0] data_in_RAM     ,
  
    output signed wire [15:0] data_out_RAM 
  );


reg [17:0] rrd_addr_RAM;
reg [17:0] rwr_addr_RAM;

reg [10:0] rclocks_counter;
reg [4 :0] rram_cycle_counter;
reg [10:0] roldest_sample_addr;


//Simple dual-port BRAM
rx_RAM rRAM(crx_clk, 1'b1, rd_en_RAM, wr_en_RAM , rwr_addr_RAM, rrd_addr_RAM, data_in_RAM, data_out_RAM);


//Counts the number of clocks between two new samples
always @(posedge crx_clk) begin
  if (rrx_rst == 1) begin
    rclock_counter = 0;
  end else begin
    if (inew_sample_trig) begin
      rclock_counter = 0;
    end else begin
      rclock_counter = rclock_counter + 1;
    end
  end
end

//Keeps track of what ram out of the 20 the sample are being writen to
always @(posedge crx_clk) begin
  if (rrx_rst == 1) begin
    rram_cycle_counter = 0;
  end else begin
    if (rram_cycle_counter >= 19) begin
      rram_cycle_counter = 0;
    end else begin
      rram_cycle_counter = rram_cycle_counter + 1;
    end
  end
end

//Updates the next address to write to every time a write enable is received
always @(posedge crx_clk) begin
  if (rrx_rst == 1) begin
    rwr_addr_RAM = 0;
  end else begin
    if (wr_en_RAM) begin
      if (rwr_addr_RAM == MEMORY_LENGTH - 1) begin
        rwr_addr_RAM = 0;
      end else begin
        rwr_addr_RAM = rwr_addr_RAM + 1;
      end
    end
  end
end

//Updates the position of the next oldest sample in the memory
always @(posedge crx_clk) begin
  if (rrx_rst == 1) begin
    roldest_sample_addr = 0;
  end else begin
    if (wr_en_RAM) begin
      if (roldest_sample_addr == MEMORY_LENGTH) begin
        roldest_sample_addr = 0;
      end else begin
        if (roldest_sample_addr == MEMORY_INDEX) begin
          roldest_sample_addr = roldest_sample_addr + 1;
        end
      end
    end
  end
end

//Updates the next address to be read every clock
always @(posedge crx_clk) begin
  if (rrx_rst == 1) begin
    rrd_addr_RAM = 0;
  end else begin
    if (inew_sample_trig) begin
      rrd_addr_RAM = roldest_sample_addr;
    end else begin
      if (rclocks_counter < 510) begin
        rrd_addr_RAM = rrd_addr_RAM + 1;
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