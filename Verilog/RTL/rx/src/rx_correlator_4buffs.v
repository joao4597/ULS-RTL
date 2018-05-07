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

module rx_correlator_buff_4units(  
  input  wire               crx_clk               ,  //clock signal
  input  wire               rrx_rst               ,  //reset signal
  input  wire               erx_en                ,  //enable signal
  
  input wire                inew_samle_trigger    ,

  //Result of the correlation of the received samples
  //by each of the possible 16 pseudo-random binary sequences
  input  wire signed [32:0] isample_correlation_0 ,
  input  wire signed [32:0] isample_correlation_1 ,
  input  wire signed [32:0] isample_correlation_2 ,
  input  wire signed [32:0] isample_correlation_3
  )

  integer w;


  reg [1:0] rtrigger_counter;

  always @(posedge crx_clk) begin
    if (rrx_rst) begin
      rtrigger_counter <= 0;
    end begin
      if (!erx_en) begin
        rtrigger_counter <= 0;
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
        .PRAM_BASE_ADDRESS(i * 256)
      )
      rx_correlator_buff_unit_0 (  
      .crx_clk             (crx_clk                                      ),
      .rrx_rst             (rrx_rst                                      ),
      .erx_en              (erx_en                                       ),
      .inew_samle_trigger  ((inew_samle_trigger && (rtrigger_counter == i)) ||
                            (rtrigger_counter == i)                      ),
      .isample_correlation (isample_correlation_0                        ),
      .iram_data_out       (wram_data_out [i]                            ), 
      .oram_r_enable       (wram_r_enable [i]                            ),  
      .oram_w_eanble       (wram_w_enable [i]                            ), 
      .oram_w_address      (wram_w_address[i]                            ), 
      .oram_r_address      (wram_r_address[i]                            ),
      .oram_data_in        (wram_data_in  [i]                            )
      )
    end
  endgenerate


  rx_BRAM_32_1024 rx_BRAM_32_1024_0(
    .crx_clk   (crx_clk),
    .rrx_rst   (rrx_rst),
    .erx_en    (erx_en ),

    .ir_enable (wassign_r_enable ),
    .iw_enable (wassign_w_enable ),
    .iw_address(wassign_w_address),
    .ir_address(wassign_r_address),

    .idata_in  (wassign_data_in  ),
  
    .odata_out (wassign_data_out )
  )

  always @(*) begin
    for (w = 0, w < 4; w = w + 1) begin
      wassign_r_enable  = wram_data_out [w];
      wassign_w_enable  = wram_r_enable [w];
      wassign_w_address = wram_w_enable [w];
      wassign_r_address = wram_w_address[w];
      wassign_data_in   = wram_r_address[w];
      wassign_data_out  = wram_data_in  [w];
    end
  end

endmodule