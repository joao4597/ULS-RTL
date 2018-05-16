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
 *  -Instantiates a 32*1024 BLOCK RAM
 *  -Instantiate for rx_correlator_buff_unit which share said RAM
 *  -Receives the result of 4 correlators which are sent to each of the 4 correlator_buff_unit
 *
 * CONSTRAINTS:
 *
 *
 */

module rx_correlator_buff_4units(  
  input  wire               crx_clk               ,  //clock signal
  input  wire               rrx_rst               ,  //reset signal
  input  wire               erx_en                ,  //enable signal
  
  input wire                inew_samle_trigger    ,

  //Result of the correlation of the received samples
  //by each of the possible 16 pseudo-random binary sequences
  input  wire signed [31:0] isample_correlation_0 ,
  input  wire signed [31:0] isample_correlation_1 ,
  input  wire signed [31:0] isample_correlation_2 ,
  input  wire signed [31:0] isample_correlation_3 ,

  input  wire         [1:0] ireceived_seq         ,  
  input  wire               istorage_wash_trigger ,  
  input  wire               inext_sample_trigger  ,  
    
  output wire signed [31:0] ocorr_sample          ,
  output reg                ocorr_sample_ready  
  );

  integer w;

  reg [1:0] rtrigger_counter;

  reg [9:0] rread_counter;

  reg rflag_buff;

  wire [3:0] wflag;

  wire [3:0]  wram_w_enable; 
  wire [9:0]  wram_w_address [3:0];
  wire [31:0] wram_data_in   [3:0];

  reg        rassign_w_enable ;
  reg [9:0]  rassign_w_address;
  reg [31:0] rassign_data_in  ;

  wire signed [31:0] wisample_correlation [3:0];

  assign wisample_correlation[0] = isample_correlation_0;
  assign wisample_correlation[1] = isample_correlation_1;
  assign wisample_correlation[2] = isample_correlation_2;
  assign wisample_correlation[3] = isample_correlation_3;


  //two bit counter used to signal each of the for correlator_buff_units when the shared ram is avaiulable to use
  always @(posedge crx_clk) begin
    if (rrx_rst) begin
      rtrigger_counter <= 0;
    end begin
      if (!erx_en) begin
        //rtrigger_counter <= 0;
      end else begin
        if ((rtrigger_counter == 0) && inew_samle_trigger) begin
          rtrigger_counter <= 1;
        end else begin
          if (rtrigger_counter > 0) begin
            rtrigger_counter <= rtrigger_counter + 1;
          end
        end
      end
    end
  end

  
  generate
    genvar i;
    for (i = 0; i < 4; i = i + 1) begin
      rx_correlator_buff_unit #(
        .RAM_BASE_ADDRESS(i * 256)
      )
      rx_correlator_buff_unit_0 (  
      .crx_clk             (crx_clk                                      ),
      .rrx_rst             (rrx_rst                                      ),
      .erx_en              (erx_en                                       ),
      .inew_samle_trigger  ((inew_samle_trigger && (rtrigger_counter == i)) ||
                           ((rtrigger_counter == i) && (i > 0))          ),
      .isample_correlation (wisample_correlation[i]                      ),
      .oram_w_eanble       (wram_w_enable[i]                             ), 
      .oram_w_address      (wram_w_address[i]                            ),
      .oram_data_in        (wram_data_in[i]                              ),
      .r_buff_flag         (wflag[i]                                     )
      );
    end
  endgenerate

  //Shared RAM
  rx_BRAM_32_1024 rx_BRAM_32_1024_0(
    .crx_clk   (crx_clk),
    .rrx_rst   (rrx_rst),
    .erx_en    (1'b1   ),

    .ir_enable (1'b1             ),
    .iw_enable (rassign_w_enable ),
    .iw_address(rassign_w_address),
    .ir_address(rread_counter    ),

    .idata_in  (rassign_data_in  ),
  
    .odata_out (ocorr_sample     )
  );

  always @(*) begin
    case (rtrigger_counter)
      0 : begin
        rassign_w_enable  = wram_w_enable [0];
        rassign_w_address = wram_w_address[0];
        rassign_data_in   = wram_data_in  [0];
      end
      1 : begin
        rassign_w_enable  = wram_w_enable [1];
        rassign_w_address = wram_w_address[1];
        rassign_data_in   = wram_data_in  [1];
      end
      2 : begin
        rassign_w_enable  = wram_w_enable [2];
        rassign_w_address = wram_w_address[2];
        rassign_data_in   = wram_data_in  [2];
      end
      3 : begin
        rassign_w_enable  = wram_w_enable [3];
        rassign_w_address = wram_w_address[3];
        rassign_data_in   = wram_data_in  [3];
      end
      default : begin
        rassign_w_enable  = 0;
        rassign_w_address = 0;
        rassign_data_in   = 0;
      end
    endcase
  end

  
  always @(posedge crx_clk) begin
    if (rrx_rst) begin
      rread_counter <= 0;
      rflag_buff    <= 0;
    end else begin
      if (istorage_wash_trigger) begin
        rread_counter <= ireceived_seq * 256 + ((!wflag[ireceived_seq]) * 128);
        rflag_buff <= 1; 
      end else begin
        if (inext_sample_trigger) begin
          rread_counter <= rread_counter + 1;
          rflag_buff <= 1; 
        end else begin
          rflag_buff <= 0; 
        end
      end
    end
  end

  //delay rflag_buff one clock, this is necessary because BRAM syncronous read
  always @(posedge crx_clk) begin
    if (rrx_rst) begin
      ocorr_sample_ready <= 0;
    end else begin
      ocorr_sample_ready <= rflag_buff;
    end
  end

endmodule


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
*                                                                             *
*              @Copyright (C) 2018, #1Nadal, All Rights Reserved              *
*                                                                             *
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */