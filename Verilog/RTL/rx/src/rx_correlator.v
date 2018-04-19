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
 * -Instantiates a module that outputs the 16 possible pseudo-random binary sequences
 * -Receives 20 samples in parallel and correlates the samples with the 16 possible signals
 * -Instantiates 10 modules responsible for correlating 2 samples each
 *
 * CONSTRAINTS:
 *
 */

module rx_correlator(
  input  wire               crx_clk           ,  //clock signal
  input  wire               rrx_rst           ,  //reset signal
  input  wire               erx_en            ,  //enable signal

  input  wire               inew_sample_trig  ,  //new sample trigger

  input  wire signed [15:0] idata_sample_0    ,
  input  wire signed [15:0] idata_sample_1    ,
  input  wire signed [15:0] idata_sample_2    ,
  input  wire signed [15:0] idata_sample_3    ,
  input  wire signed [15:0] idata_sample_4    ,
  input  wire signed [15:0] idata_sample_5    ,
  input  wire signed [15:0] idata_sample_6    ,
  input  wire signed [15:0] idata_sample_7    ,
  input  wire signed [15:0] idata_sample_8    ,
  input  wire signed [15:0] idata_sample_9    ,
  input  wire signed [15:0] idata_sample_10   ,
  input  wire signed [15:0] idata_sample_11   ,
  input  wire signed [15:0] idata_sample_12   ,
  input  wire signed [15:0] idata_sample_13   ,
  input  wire signed [15:0] idata_sample_14   ,
  input  wire signed [15:0] idata_sample_15   ,
  input  wire signed [15:0] idata_sample_16   ,
  input  wire signed [15:0] idata_sample_17   ,
  input  wire signed [15:0] idata_sample_18   ,
  input  wire signed [15:0] idata_sample_19   ,

  output wire signed [40:0] ocorrelation_seq_0 ,
  output wire signed [40:0] ocorrelation_seq_1 ,
  output wire signed [40:0] ocorrelation_seq_2 ,
  output wire signed [40:0] ocorrelation_seq_3 ,
  output wire signed [40:0] ocorrelation_seq_4 ,
  output wire signed [40:0] ocorrelation_seq_5 ,
  output wire signed [40:0] ocorrelation_seq_6 ,
  output wire signed [40:0] ocorrelation_seq_7 ,
  output wire signed [40:0] ocorrelation_seq_8 ,
  output wire signed [40:0] ocorrelation_seq_9 ,
  output wire signed [40:0] ocorrelation_seq_10,
  output wire signed [40:0] ocorrelation_seq_11,
  output wire signed [40:0] ocorrelation_seq_12,
  output wire signed [40:0] ocorrelation_seq_13,
  output wire signed [40:0] ocorrelation_seq_14,
  output wire signed [40:0] ocorrelation_seq_15, 

  output reg                onew_result_trigger
  );

  wire signed [16:0] wresult      [19:0];

  wire        [15:0] wsequences;
  wire               wbit_ready;

  reg signed [40:0] rcorrelation_units_sum    ;
  reg signed [40:0] rcorrelation_result [15:0];

  reg rbit_ready_one_clk_delay;
  reg rnew_sample_trig_delay1;
  reg rnew_sample_trig_delay2;
  reg rnew_sample_trig_delay3;
  reg rnew_sample_trig_delay4;  

  rx_correlation_unit #(
    .SAMPLE_POSITION(0)
  )
  rx_correlation_unit_0 (
    .crx_clk         (crx_clk         ),  //clock signal
    .rrx_rst         (rrx_rst         ),  //reset signal
    .erx_en          (erx_en          ),  //enable signal

    .inew_sample_trig(inew_sample_trig),

    .isample         (idata_sample_0  ),
    .isample_plus_ten(idata_sample_10 ),

    .obit_ready      (wbit_ready      ),
    .oresult_0       (wresult[0]      ),
    .oresult_1       (wresult[10]     )
  );

  rx_correlation_unit #(
    .SAMPLE_POSITION(1)
  )
  rx_correlation_unit_1 (
    .crx_clk         (crx_clk         ),  //clock signal
    .rrx_rst         (rrx_rst         ),  //reset signal
    .erx_en          (erx_en          ),  //enable signal

    .inew_sample_trig(inew_sample_trig),

    .isample         (idata_sample_1  ),
    .isample_plus_ten(idata_sample_11 ),

    //.obit_ready      (wbit_ready      ),
    .oresult_0       (wresult[1]      ),
    .oresult_1       (wresult[11]     )
  );

  rx_correlation_unit #(
    .SAMPLE_POSITION(2)
  )
  rx_correlation_unit_2 (
    .crx_clk         (crx_clk         ),  //clock signal
    .rrx_rst         (rrx_rst         ),  //reset signal
    .erx_en          (erx_en          ),  //enable signal

    .inew_sample_trig(inew_sample_trig),

    .isample         (idata_sample_2  ),
    .isample_plus_ten(idata_sample_12 ),

    //.obit_ready      (wbit_ready      ),
    .oresult_0       (wresult[2]      ),
    .oresult_1       (wresult[12]     )
  );

  rx_correlation_unit #(
    .SAMPLE_POSITION(3)
  )
  rx_correlation_unit_3 (
    .crx_clk         (crx_clk         ),  //clock signal
    .rrx_rst         (rrx_rst         ),  //reset signal
    .erx_en          (erx_en          ),  //enable signal

    .inew_sample_trig(inew_sample_trig),

    .isample         (idata_sample_3  ),
    .isample_plus_ten(idata_sample_13 ),

    //.obit_ready      (wbit_ready      ),
    .oresult_0       (wresult[3]      ),
    .oresult_1       (wresult[13]     )
  );

  rx_correlation_unit #(
    .SAMPLE_POSITION(4)
  )
  rx_correlation_unit_4 (
    .crx_clk         (crx_clk         ),  //clock signal
    .rrx_rst         (rrx_rst         ),  //reset signal
    .erx_en          (erx_en          ),  //enable signal

    .inew_sample_trig(inew_sample_trig),

    .isample         (idata_sample_4  ),
    .isample_plus_ten(idata_sample_14 ),

    //.obit_ready      (wbit_ready      ),
    .oresult_0       (wresult[4]      ),
    .oresult_1       (wresult[14]     )
  );

  rx_correlation_unit #(
    .SAMPLE_POSITION(5)
  )
  rx_correlation_unit_5 (
    .crx_clk         (crx_clk         ),  //clock signal
    .rrx_rst         (rrx_rst         ),  //reset signal
    .erx_en          (erx_en          ),  //enable signal

    .inew_sample_trig(inew_sample_trig),

    .isample         (idata_sample_5  ),
    .isample_plus_ten(idata_sample_15 ),

    //.obit_ready      (wbit_ready      ),
    .oresult_0       (wresult[5]      ),
    .oresult_1       (wresult[15]     )
  );

  rx_correlation_unit #(
    .SAMPLE_POSITION(6)
  )
  rx_correlation_unit_6 (
    .crx_clk         (crx_clk         ),  //clock signal
    .rrx_rst         (rrx_rst         ),  //reset signal
    .erx_en          (erx_en          ),  //enable signal

    .inew_sample_trig(inew_sample_trig),

    .isample         (idata_sample_6  ),
    .isample_plus_ten(idata_sample_16 ),

    //.obit_ready      (wbit_ready      ),
    .oresult_0       (wresult[6]      ),
    .oresult_1       (wresult[16]     )
  );

  rx_correlation_unit #(
    .SAMPLE_POSITION(7)
  )
  rx_correlation_unit_7 (
    .crx_clk         (crx_clk         ),  //clock signal
    .rrx_rst         (rrx_rst         ),  //reset signal
    .erx_en          (erx_en          ),  //enable signal

    .inew_sample_trig(inew_sample_trig),

    .isample         (idata_sample_7  ),
    .isample_plus_ten(idata_sample_17 ),

    //.obit_ready      (wbit_ready      ),
    .oresult_0       (wresult[7]      ),
    .oresult_1       (wresult[17]     )
  );


  rx_correlation_unit #(
    .SAMPLE_POSITION(8)
  )
  rx_correlation_unit_8 (
    .crx_clk         (crx_clk         ),  //clock signal
    .rrx_rst         (rrx_rst         ),  //reset signal
    .erx_en          (erx_en          ),  //enable signal

    .inew_sample_trig(inew_sample_trig),

    .isample         (idata_sample_8  ),
    .isample_plus_ten(idata_sample_18 ),

    //.obit_ready      (wbit_ready      ),
    .oresult_0       (wresult[8]      ),
    .oresult_1       (wresult[18]     )
  );

  rx_correlation_unit #(
    .SAMPLE_POSITION(9)
  )
  rx_correlation_unit_9 (
    .crx_clk         (crx_clk         ),  //clock signal
    .rrx_rst         (rrx_rst         ),  //reset signal
    .erx_en          (erx_en          ),  //enable signal

    .inew_sample_trig(inew_sample_trig),

    .isample         (idata_sample_9  ),
    .isample_plus_ten(idata_sample_19 ),

    //.obit_ready      (wbit_ready      ),
    .oresult_0       (wresult[9]      ),
    .oresult_1       (wresult[19]     )
  );


  rx_sequences_bits_feader rx_sequences_bits_feader_0(
    .crx_clk         (crx_clk                ),  //clock signal
    .rrx_rst         (rrx_rst                ),  //reset signal
    .erx_en          (erx_en                 ),  //enable signal

    .inew_sample_trig(rnew_sample_trig_delay2),  //new sample trigger

    .osequences_bits (wsequences             )   //16 bits corresponding to the 16 binary sequences
  );

  always @(posedge crx_clk) begin
    if (rrx_rst) begin
      rcorrelation_units_sum <= 0;
    end else begin
      if (!erx_en) begin
        rcorrelation_units_sum <= 0;
      end else begin
        rcorrelation_units_sum <= wresult[0]  + wresult[1]  + wresult[2]  + wresult[3]  + wresult[4]  + wresult[5]  +
                                  wresult[6]  + wresult[7]  + wresult[8]  + wresult[9]  + wresult[10] + wresult[11] +
                                  wresult[12] + wresult[13] + wresult[14] + wresult[15] + wresult[16] + wresult[17] +
                                  wresult[18] + wresult[19];
      end
    end
  end


  //Delays the wbit_ready signal from the correlation units
  //this is necessary because it takes an extra clock to add all the correlation units
  //before they can be added or subtracted to each of the 16 rcorrelation_result registers
  //according to the 16 possible pseudo-random binary sequences
  always @(posedge crx_clk) begin
    if (rrx_rst) begin
      rbit_ready_one_clk_delay <= 0;
    end else begin
      if (!erx_en) begin
        rbit_ready_one_clk_delay <= 0;
      end else begin
        rbit_ready_one_clk_delay <= wbit_ready;
      end
    end
  end


  always @(posedge crx_clk) begin
    if (rrx_rst) begin
      rnew_sample_trig_delay1 <= 0;
      rnew_sample_trig_delay2 <= 0;
      rnew_sample_trig_delay3 <= 0;
      rnew_sample_trig_delay4 <= 0;
    end else begin
      if (!erx_en) begin
        rnew_sample_trig_delay1 <= 0;
        rnew_sample_trig_delay2 <= 0;
        rnew_sample_trig_delay3 <= 0;
        rnew_sample_trig_delay4 <= 0;
      end else begin
        rnew_sample_trig_delay1 <= inew_sample_trig;
        rnew_sample_trig_delay2 <= rnew_sample_trig_delay1;
        rnew_sample_trig_delay3 <= rnew_sample_trig_delay2;
        rnew_sample_trig_delay4 <= rnew_sample_trig_delay3;
      end
    end
  end


  //these registers accumulate the correlation of the received signal for each of the 16 possible sequences
  //each new result form the correlation units is either added or subtracted according to the bits of each sequence
  generate
    genvar i;
    for (i = 0; i < 16; i = i + 1) begin
      always @(posedge crx_clk) begin
        if (rrx_rst) begin
          rcorrelation_result[i] <= 0;
        end else begin
          if (!erx_en) begin
            rcorrelation_result[i] <= 0;
          end else begin
            if (rnew_sample_trig_delay2) begin
              rcorrelation_result[i] <= 0;
            end else begin
              if (rbit_ready_one_clk_delay) begin
                if (wsequences[i])begin
                  rcorrelation_result[i] <= rcorrelation_result[i] + rcorrelation_units_sum;
                end else begin
                  rcorrelation_result[i] <= rcorrelation_result[i] - rcorrelation_units_sum;
                end
              end
            end
          end
        end 
      end
    end
  endgenerate

  assign ocorrelation_seq_0  = rcorrelation_result[0] ;
  assign ocorrelation_seq_1  = rcorrelation_result[1] ;
  assign ocorrelation_seq_2  = rcorrelation_result[2] ;
  assign ocorrelation_seq_3  = rcorrelation_result[3] ;
  assign ocorrelation_seq_4  = rcorrelation_result[4] ;
  assign ocorrelation_seq_5  = rcorrelation_result[5] ;
  assign ocorrelation_seq_6  = rcorrelation_result[6] ;
  assign ocorrelation_seq_7  = rcorrelation_result[7] ;
  assign ocorrelation_seq_8  = rcorrelation_result[8] ;
  assign ocorrelation_seq_9  = rcorrelation_result[9] ;
  assign ocorrelation_seq_10 = rcorrelation_result[10];
  assign ocorrelation_seq_11 = rcorrelation_result[11];
  assign ocorrelation_seq_12 = rcorrelation_result[12];
  assign ocorrelation_seq_13 = rcorrelation_result[13];
  assign ocorrelation_seq_14 = rcorrelation_result[14];
  assign ocorrelation_seq_15 = rcorrelation_result[15];


  //trigger activated when new result of the correlation is available
  always @(posedge crx_clk) begin
    if (rrx_rst) begin
      onew_result_trigger <= 0; 
    end else begin
      if (!erx_en) begin
        onew_result_trigger <= 0;
      end else begin
        if (rnew_sample_trig_delay1) begin
          onew_result_trigger <= 1;
        end else begin
          onew_result_trigger <= 0;
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
