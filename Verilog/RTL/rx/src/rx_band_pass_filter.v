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

module rx_band_pass_filter(
  input  wire               crx_clk         ,  //clock signal
  input  wire               rrx_rst         ,  //reset signal
  input  wire               erx_en          ,  //enable signal
  input  wire signed [15:0] idata_in_RAM    ,  //new sample to be stored

  output reg                osample_ready   ,  //set to one when a new sample is ready
  output wire signed [15:0] ofiltered_sample
  );

  wire signed [15:0] wcoeff_read ;
  wire signed [15:0] wsample_read;

  wire wnew_sample_trigg;

  reg  [8:0] rread_address_RAM     ;
  
  reg  [8:0] rwrite_address_samples;
  reg  [8:0] rread_address_samples ;

  reg signed [69:0] rfiltered_sample_acum ;
  reg signed [69:0] rfiltered_sample_final;

  wire signed [69:0] widata_in_RAM_extended;
  wire signed [69:0] wwcoeff_read_extended ;
  wire signed [69:0] wwsample_read_extended;


  //anticipates when a new sample is coming based on the read address of the samples memory
  assign wnew_sample_trigg = rread_address_RAM == 0 ? 1'b1 : 1'b0;


  //RAM that holds the low pass filter coefficients
  rx_BRAM_16_512_band_pass rx_BRAM_16_512_band_pass_0(crx_clk, rrx_rst, 1'b1, 1'b1, 0'b0, 0, rread_address_RAM, 0, wcoeff_read);

  //RAM that holds the last 128 samples
  rx_BRAM_16_512 rx_BRAM_16_512_0(
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
      osample_ready <= 0;
    end else begin
      if (!erx_en) begin
        osample_ready <= 0;
      end else begin
        osample_ready <= wnew_sample_trigg;
      end
    end
  end


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
      rread_address_samples <= 1;
    end else begin
      if (!erx_en) begin
        rread_address_samples <= 1;
      end else begin
        if (rread_address_RAM == 511) begin
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
          rfiltered_sample_final <= rfiltered_sample_acum + (widata_in_RAM_extended * wwcoeff_read_extended);
          rfiltered_sample_acum  <= 0;
        end else begin
          rfiltered_sample_acum  <= rfiltered_sample_acum + (wwsample_read_extended * wwcoeff_read_extended);
        end
      end
    end
  end


  assign widata_in_RAM_extended = $signed(idata_in_RAM);
  assign wwcoeff_read_extended  = $signed(wcoeff_read );
  assign wwsample_read_extended = $signed(wsample_read);


  assign ofiltered_sample = rfiltered_sample_final[25:10];
  //assign ofiltered_sample = rfiltered_sample_final[15:0];


endmodule


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
*                                                                             *
*              @Copyright (C) 2018, #1Nadal, All Rights Reserved              *
*                                                                             *
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
