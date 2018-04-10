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

module rx_low_pass_filter(
  input  wire               crx_clk         ,  //clock signal
  input  wire               rrx_rst         ,  //reset signal
  input  wire               erx_en          ,  //enable signal
  input  wire signed [15:0] idata_in_RAM    ,  //new sample to be stored

  output wire signed [15:0] ofiltered_sample
  );

  wire signed [15:0] wcoeff_read ;
  wire signed [15:0] wsample_read;

  wire wnew_sample_trigg;

  reg [6:0] rread_address_RAM;

  reg [6:0] rwrite_address_samples;
  reg [6:0] rread_address_samples ;

  reg [40:0] rfiltered_sample_acum ;
  reg [40:0] rfiltered_sample_final;


  //anticipates when a new sample is comming based on the read adderess of the samples memory
  assign wnew_sample_trigg = rread_address_RAM == 127 ? 1'b1 : 1'b0;


  //RAM that holds the low pass filter coefficients
  rx_BRAM_16_128_low_pass rx_BRAM_16_128_low_pass_0(crx_clk, rrx_rst, 1'b1, 1'b1, 0'b0, 0, rread_address_RAM, 0, wcoeff_read);

  //RAM that holds the last 128 samples
  rx_BRAM_16_128 rx_BRAM_16_128_0(
    .clk    (crx_clk               ),  //clock
    .rrx_rst(rrx_rst               ),  //reset
    .ena    (erx_en                ),  //enable
    .enb    (1'b1                  ),  //enable read
    .wea    (wnew_sample_trigg     ),  //write enable
    .addra  (rwrite_address_samples),  //write address
    .addrb  (rread_address_samples ),  //read addr
    .dia    (idata_in_RAM          ),  //data in
    .dob    (wsample_read          )   //data out
    );


  //Reads the filter coefficients in Round Robin
  always @(posedge crx_clk) begin
    if (rrx_rst) begin
      rread_address_RAM <= 0;
    end else begin
      if (!erx_en) begin
        rread_address_RAM <= 0;
      end else begin
        rread_address_RAM <= rread_address_RAM + 1;
      end
    end
  end


  //Keeps track of the memory address the next incoming sample will be stored in
  always @(posedge crx_clk) begin
    if (rrx_rst) begin
      rwrite_address_samples <= 0;
    end else begin
      if (!erx_en) begin
        rwrite_address_samples <= 0;
      end else begin
        if (wnew_sample_trigg) begin
          rwrite_address_samples <= rwrite_address_samples + 1;
        end
      end
    end
  end


  //Increments the read address to access the stored samples
  always @(posedge crx_clk) begin
    if (rrx_rst) begin
      rread_address_samples <= 0;
    end else begin
      if (!erx_en) begin
        rread_address_samples <= 0;
      end else begin
        if (wnew_sample_trigg) begin
          rread_address_samples <= rread_address_samples + 2;
        end else begin
          rread_address_samples <= rread_address_samples + 1;
        end
      end
    end
  end


  //Acumulates the result of the multiplication of the samples by the filter coefficients
  always @(posedge crx_clk) begin
    if (rrx_rst) begin
      rfiltered_sample_acum  <= 0;
      rfiltered_sample_final <= 0;
    end else begin
      if (!erx_en) begin
        rfiltered_sample_acum  <= 0;
        rfiltered_sample_final <= 0;
      end else begin
        if (wnew_sample_trigg) begin
          rfiltered_sample_final <= rfiltered_sample_acum + (idata_in_RAM * wcoeff_read);
          rfiltered_sample_acum  <= 0;
        end
          rfiltered_sample_acum <= rfiltered_sample_acum + (wsample_read * wcoeff_read);
      end
    end
  end


  assign ofiltered_sample = rfiltered_sample_final[15:0]  +
                            rfiltered_sample_final[31:16] +
                            rfiltered_sample_final[40:32];


endmodule


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
*                                                                             *
*              @Copyright (C) 2018, #1Nadal, All Rights Reserved              *
*                                                                             *
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
