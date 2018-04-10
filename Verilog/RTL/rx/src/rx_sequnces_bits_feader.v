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
 * - instantiates a 16 by 256 bit memory that keeps the 16 pseudo-random binary sequences
 * - at each two clocks outputs a bit from each of the 16 sequences
 *
 * CONSTRAINTS:
 *
 */

module rx_sequences_bits_feader(
  input  wire        crx_clk        ,  //clock signal
  input  wire        rrx_rst         ,  //reset signal
  input  wire        erx_en          ,  //enable signal

  input  wire        inew_sample_trig,  //new sample trigger

  output wire [15:0] osequences_bits    //16 bits corresponding to the 16 binary sequences
  );

  //This flag is incremented at each clock, oscillates between one and zero
  //used to divide the clock
  reg flag;

  reg [7:0] rread_address;


  rx_BRAM_16_256_binary_sequences rx_BRAM_16_256_binary_sequences_0(crx_clk, erx_en, 1'b1, 1'b0, 8'b0, rread_address, 16'b0, osequences_bits);


  //Updates the read address of the memory that keeps the binary sequences
  always @(posedge crx_clk) begin
    if (rrx_rst) begin
      rread_address <= 0;
      flag <= 0;
    end else begin
      if (!erx_en) begin
        rread_address <= 0;
        flag <= 0;
      end else begin
        if(inew_sample_trig) begin
          rread_address <= 0;
          flag          <= 0;
        end else begin
          flag <= flag + 1;
          if (rread_address < 254 && flag) begin
            rread_address <= rread_address + 1;
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
