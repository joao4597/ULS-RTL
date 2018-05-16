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

  input wire                inew_samle_trigger    ,

  //Result of the correlation of the received samples
  //by each of the possible 16 pseudo-random binary sequences
  input  wire signed [31:0] isample_correlation_0 ,
  input  wire signed [31:0] isample_correlation_1 ,
  input  wire signed [31:0] isample_correlation_2 ,
  input  wire signed [31:0] isample_correlation_3 ,
  input  wire signed [31:0] isample_correlation_4 ,
  input  wire signed [31:0] isample_correlation_5 ,
  input  wire signed [31:0] isample_correlation_6 ,
  input  wire signed [31:0] isample_correlation_7 ,
  input  wire signed [31:0] isample_correlation_8 ,
  input  wire signed [31:0] isample_correlation_9 ,
  input  wire signed [31:0] isample_correlation_10,
  input  wire signed [31:0] isample_correlation_11,
  input  wire signed [31:0] isample_correlation_12,
  input  wire signed [31:0] isample_correlation_13,
  input  wire signed [31:0] isample_correlation_14,
  input  wire signed [31:0] isample_correlation_15,

  input  wire         [3:0] ireceived_seq         ,
  input  wire               istorage_wash_enable  ,
  input  wire               inext_sample_trigger  ,
  input  wire               iall_acquired_trigg   ,

  output reg  signed [31:0] ocorr_sample          ,
  output reg                ocorr_sample_ready                    

  );

  reg [3:0] rreceived_seq;

  wire signed [31:0] wcorr_sample [3:0];
  wire         [3:0] wcorr_sample_ready;

  reg rstorage_wash_trigger_0; 
  reg rstorage_wash_trigger_1;

  wire wstorage_wash_trigger;

  reg rcorr_4buff_en;

  always @(posedge crx_clk) begin
    if (rrx_rst) begin
      rreceived_seq <= 0;
    end else begin
      if (!erx_en) begin
        rreceived_seq <= 0;
      end else begin
        if (istorage_wash_enable) begin
          rreceived_seq <= ireceived_seq;
        end
      end
    end
  end

  rx_correlator_buff_4units rx_correlator_buff_4units_0(
    .crx_clk              (crx_clk               ),
    .rrx_rst              (rrx_rst || iall_acquired_trigg),
    .erx_en               (erx_en && rcorr_4buff_en ),
    
    .inew_samle_trigger   (inew_samle_trigger    ),
    
    .isample_correlation_0(isample_correlation_0 ),
    .isample_correlation_1(isample_correlation_1 ),
    .isample_correlation_2(isample_correlation_2 ),
    .isample_correlation_3(isample_correlation_3 ),
    
    .ireceived_seq        (rreceived_seq[1:0]    ),  
    .istorage_wash_trigger(wstorage_wash_trigger ),  
    .inext_sample_trigger (inext_sample_trigger  ),  
    
    .ocorr_sample         (wcorr_sample[0]       ),
    .ocorr_sample_ready   (wcorr_sample_ready[0] )
  );

  rx_correlator_buff_4units rx_correlator_buff_4units_1(
    .crx_clk              (crx_clk               ),
    .rrx_rst              (rrx_rst || iall_acquired_trigg),
    .erx_en               (erx_en && rcorr_4buff_en ),
    
    .inew_samle_trigger   (inew_samle_trigger    ),
    
    .isample_correlation_0(isample_correlation_4 ),
    .isample_correlation_1(isample_correlation_5 ),
    .isample_correlation_2(isample_correlation_6 ),
    .isample_correlation_3(isample_correlation_7 ),
    
    .ireceived_seq        (rreceived_seq[1:0]    ),  
    .istorage_wash_trigger(wstorage_wash_trigger ),  
    .inext_sample_trigger (inext_sample_trigger  ),  
    
    .ocorr_sample         (wcorr_sample[1]       ),
    .ocorr_sample_ready   (wcorr_sample_ready[1] )
  );

  rx_correlator_buff_4units rx_correlator_buff_4units_2(
    .crx_clk              (crx_clk               ),
    .rrx_rst              (rrx_rst || iall_acquired_trigg),
    .erx_en               (erx_en && rcorr_4buff_en ),
    
    .inew_samle_trigger   (inew_samle_trigger    ),
    
    .isample_correlation_0(isample_correlation_8 ),
    .isample_correlation_1(isample_correlation_9 ),
    .isample_correlation_2(isample_correlation_10),
    .isample_correlation_3(isample_correlation_11),
    
    .ireceived_seq        (rreceived_seq[1:0]    ),  
    .istorage_wash_trigger(wstorage_wash_trigger ),  
    .inext_sample_trigger (inext_sample_trigger  ),  
    
    .ocorr_sample         (wcorr_sample[2]       ),
    .ocorr_sample_ready   (wcorr_sample_ready[2] )
  );

  rx_correlator_buff_4units rx_correlator_buff_4units_3(
    .crx_clk              (crx_clk               ),
    .rrx_rst              (rrx_rst || iall_acquired_trigg),
    .erx_en               (erx_en && rcorr_4buff_en ),
    
    .inew_samle_trigger   (inew_samle_trigger    ),
    
    .isample_correlation_0(isample_correlation_12),
    .isample_correlation_1(isample_correlation_13),
    .isample_correlation_2(isample_correlation_14),
    .isample_correlation_3(isample_correlation_15),
    
    .ireceived_seq        (rreceived_seq[1:0]    ),  
    .istorage_wash_trigger(wstorage_wash_trigger ),  
    .inext_sample_trigger (inext_sample_trigger  ),  
    
    .ocorr_sample         (wcorr_sample[3]       ),
    .ocorr_sample_ready   (wcorr_sample_ready[3] )
  );


  always @(*) begin
    case (rreceived_seq[3:2])
      2'b00: begin
        ocorr_sample       = wcorr_sample[0]      ;
        ocorr_sample_ready = wcorr_sample_ready[0];
      end
      2'b01: begin
        ocorr_sample       = wcorr_sample[1]      ;
        ocorr_sample_ready = wcorr_sample_ready[1];
      end
      2'b10: begin
        ocorr_sample       = wcorr_sample[2]      ;
        ocorr_sample_ready = wcorr_sample_ready[2];
      end
      2'b11: begin
        ocorr_sample       = wcorr_sample[3]      ;
        ocorr_sample_ready = wcorr_sample_ready[3];
      end
    endcase
  end

  always @(posedge crx_clk) begin
    if (rrx_rst || iall_acquired_trigg) begin
      rstorage_wash_trigger_0 <= 0;
      rstorage_wash_trigger_1 <= 0;
    end else begin
      if (!erx_en) begin
        rstorage_wash_trigger_0 <= 0;
        rstorage_wash_trigger_1 <= 0;
      end else begin
        rstorage_wash_trigger_0 <= istorage_wash_enable   ;
        rstorage_wash_trigger_1 <= rstorage_wash_trigger_0;
      end
    end
  end


  assign wstorage_wash_trigger = rstorage_wash_trigger_0 && (!rstorage_wash_trigger_1);


  always @(posedge crx_clk) begin
    if (rrx_rst || iall_acquired_trigg) begin
      rcorr_4buff_en <= 1;
    end else begin
      if (!erx_en) begin
        rcorr_4buff_en <= 1;
      end else begin
        if (wstorage_wash_trigger) begin
          rcorr_4buff_en <= 0;
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