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

module rx_correlator_buff (  
  input  wire               crx_clk               ,  //clock signal
  input  wire               rrx_rst               ,  //reset signal
  input  wire               erx_en                ,  //enable signal
   
  input  wire signed [15:0] isample_filtered      ,  //output of band_pass filter
                                                     //used to identify when a symbol
                                                     //has been received
  
  input wire                inew_samle_trigger    ,

  //Result of the correlation of the received samples
  //by each of the possible 16 pseudo-random binary sequences
  input  wire signed [40:0] isample_correlation_0 ,
  input  wire signed [40:0] isample_correlation_1 ,
  input  wire signed [40:0] isample_correlation_2 ,
  input  wire signed [40:0] isample_correlation_3 ,
  input  wire signed [40:0] isample_correlation_4 ,
  input  wire signed [40:0] isample_correlation_5 ,
  input  wire signed [40:0] isample_correlation_6 ,
  input  wire signed [40:0] isample_correlation_7 ,
  input  wire signed [40:0] isample_correlation_8 ,
  input  wire signed [40:0] isample_correlation_9 ,
  input  wire signed [40:0] isample_correlation_10,
  input  wire signed [40:0] isample_correlation_11,
  input  wire signed [40:0] isample_correlation_12,
  input  wire signed [40:0] isample_correlation_13,
  input  wire signed [40:0] isample_correlation_14,
  input  wire signed [40:0] isample_correlation_15,

  output reg  signed [40:0] o_sample_arm          ,  //Peak Value
  output reg          [3:0] o_received_seq        ,
  output reg         [15:0] o_time_arm            ,  //Timestamp
  output reg                o_trigger_arm            //Trigger
  );



  rx_correlator_buff_4units rx_correlator_buff_4units_0(
    .crx_clk              (crx_clk               ),
    .rrx_rst              (rrx_rst               ),
    .erx_en               (erx_en                ),
    .inew_samle_trigger   (inew_samle_trigger    ),
    .isample_correlation_0(isample_correlation_0 ),
    .isample_correlation_1(isample_correlation_1 ),
    .isample_correlation_2(isample_correlation_2 ),
    .isample_correlation_3(isample_correlation_3 )
  )

  rx_correlator_buff_4units rx_correlator_buff_4units_1(
    .crx_clk              (crx_clk               ),
    .rrx_rst              (rrx_rst               ),
    .erx_en               (erx_en                ),
    .inew_samle_trigger   (inew_samle_trigger    ),
    .isample_correlation_0(isample_correlation_4 ),
    .isample_correlation_1(isample_correlation_5 ),
    .isample_correlation_2(isample_correlation_6 ),
    .isample_correlation_3(isample_correlation_7 )
  )

  rx_correlator_buff_4units rx_correlator_buff_4units_2(
    .crx_clk              (crx_clk               ),
    .rrx_rst              (rrx_rst               ),
    .erx_en               (erx_en                ),
    .inew_samle_trigger   (inew_samle_trigger    ),
    .isample_correlation_0(isample_correlation_8 ),
    .isample_correlation_1(isample_correlation_9 ),
    .isample_correlation_2(isample_correlation_10),
    .isample_correlation_3(isample_correlation_11)
  )

  rx_correlator_buff_4units rx_correlator_buff_4units_3(
    .crx_clk              (crx_clk               ),
    .rrx_rst              (rrx_rst               ),
    .erx_en               (erx_en                ),
    .inew_samle_trigger   (inew_samle_trigger    ),
    .isample_correlation_0(isample_correlation_12),
    .isample_correlation_1(isample_correlation_13),
    .isample_correlation_2(isample_correlation_14),
    .isample_correlation_3(isample_correlation_15)
  )

endmodule