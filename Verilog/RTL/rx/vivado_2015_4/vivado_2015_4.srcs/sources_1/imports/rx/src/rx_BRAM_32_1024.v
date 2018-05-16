// Simple Dual-Port Block RAM with One Clock
// File: simple_dual_one_clock.v

/**
 * GENERAL DESCRIPTION:
 *
 * -Multipurpose 16 bit by 128 lines RAM
 *
 *
 * CONSTRAINTS:
 *
 *
 */

module rx_BRAM_32_1024(
  input  wire               crx_clk               ,  //clock signal
  input  wire               rrx_rst               ,  //reset signal
  input  wire               erx_en                ,  //enable signal

  input  wire               ir_enable             ,
  input  wire               iw_enable             ,
  input  wire        [9:0]  iw_address            ,
  input  wire        [9:0]  ir_address            ,

  input  wire signed [31:0] idata_in              ,
  
  output reg  signed [31:0] odata_out
  );

  reg signed [31:0] BRAM [1023:0];

  integer i;

  //set initial value of memories to zero
  initial begin
    for (i = 0; i < 1024; i = i + 1) begin
      BRAM[i] = 0;
    end
  end

  always @(posedge crx_clk) begin
    if (erx_en) begin
      if (iw_enable) begin
        BRAM[iw_address] <= idata_in;
      end
    end
  end

  always @(posedge crx_clk) begin
    if (rrx_rst) begin
      odata_out <= 0;
    end else begin
      if (!erx_en) begin
        //odata_out <= 0;
      end else begin
        if (ir_enable) begin
          odata_out <= BRAM[ir_address];
        end
      end
    end
  end

endmodule
