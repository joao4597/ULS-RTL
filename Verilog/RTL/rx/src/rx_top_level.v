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
 * -Receives one sample every 128 clocks
 * -Applies a low pass filter and decimates samples by 4
 * -Applies a Band-pass filter to the decimated samples
 * -Stores the samples in 20 RAMS so 20 samples can be access in parallel every clock
 * -Correlates the filtered samples with the 16 possible signals
 * -Detects a correlation peak and identifies the received signal
 * -Outputs the received sequence with a timestamps
 *
 *
 * CONSTRAINTS:
 *
 *
 */

module rx_top_level(
  input  wire               crx_clk       ,  //clock signal
  input  wire               rrx_rst       ,  //reset signal
  input  wire               erx_en        ,  //enable signal
 
  input  wire signed [15:0] inew_sample   ,  //new sample in

  output wire signed [40:0] o_sample_arm  ,  //Peak Value
  output wire         [3:0] o_received_seq,
  output wire        [15:0] o_time_arm    ,  //Timestamp
  output wire               o_trigger_arm    //Trigger
  );

  reg new_sample_trig_delay_1;
  

  //Outputs of rx_low_pass_filter
  wire signed [15:0] wfiltered_sample_low_pass;


  //Inputs of rx_band_pass_filter
  reg rrx_rst_1;
  //Outputs of rx_band_pass_filter
  wire signed [15:0] wfiltered_sample_band_pass;
  wire               wband_pass_sample_ready   ;
  reg  signed [15:0] rfiltered_sample_band_pass;

  
  //Inputs of samples organizer
  reg new_sample_trig_delay_3;
  //Outputs of samples organizer
  wire signed [15:0] wparallel_samples [19:0];


  //Inputs of rx_correaltor
  reg new_sample_trig_delay_4;
  //Outputs of rx_correlator
  wire wcorrelator_trigger;
  wire signed [40:0] wcorrelation_result [15:0];


  /////////////////////////////////////////////////LOW_PASS_FILTER//////////////////////////////////////////////////////
  //Low pass filter
  rx_low_pass_filter rx_low_pass_filter_0(
  .crx_clk         (crx_clk                  ),  //clock signal
  .rrx_rst         (rrx_rst                  ),  //reset signal
  .erx_en          (erx_en                   ),  //enable signal
  .idata_in_RAM    (inew_sample              ),  //new sample to be stored

  .ofiltered_sample(wfiltered_sample_low_pass)
  );
  //This block dealys the samples flow by one clock



  ////////////////////////////////////////////////BAND_PASS_FILTER//////////////////////////////////////////////////////
  //Delay the enqable signal one clock
  always @(posedge crx_clk) begin
    if (rrx_rst) begin
      rrx_rst_1 <= 1;
    end else begin
      if (!erx_en) begin
        rrx_rst_1 <= 1;
      end else begin
        rrx_rst_1 <= rrx_rst;
      end
    end
  end
  
  //Band pass filter
  rx_band_pass_filter rx_band_pass_filter_0(
  .crx_clk         (crx_clk                   ),  //clock signal
  .rrx_rst         (rrx_rst_1                 ),  //reset signal
  .erx_en          (erx_en                    ),  //enable signal
  .idata_in_RAM    (wfiltered_sample_low_pass ),  //new sample to be stored

  .osample_ready   (wband_pass_sample_ready   ),
  .ofiltered_sample(wfiltered_sample_band_pass)
  );
  //This block dealys the samples flow by one clock



  ////////////////////////////////////////////////SAMPLES_ORGANIZER/////////////////////////////////////////////////////
  //stores incoming samples and outputs 20 of the stored samples every clock
  //in parallel
  rx_samples_organizer rx_samples_organizer_0(
    .crx_clk         (crx_clk                   ),  //clock signal
    .rrx_rst         (rrx_rst                   ),  //reset signal
    .erx_en          (erx_en                    ),  //enable signal
    .idata_in_RAM    (wfiltered_sample_band_pass),  //new sample to be stored

    .inew_sample_trig(wband_pass_sample_ready   ),  //new sample trigger

    //20 ordered samples outputted in parallel
    .odata_0         (wparallel_samples[0]      ),
    .odata_1         (wparallel_samples[1]      ),
    .odata_2         (wparallel_samples[2]      ),
    .odata_3         (wparallel_samples[3]      ),
    .odata_4         (wparallel_samples[4]      ),
    .odata_5         (wparallel_samples[5]      ),
    .odata_6         (wparallel_samples[6]      ),
    .odata_7         (wparallel_samples[7]      ),
    .odata_8         (wparallel_samples[8]      ),
    .odata_9         (wparallel_samples[9]      ),
    .odata_10        (wparallel_samples[10]     ),
    .odata_11        (wparallel_samples[11]     ),
    .odata_12        (wparallel_samples[12]     ),
    .odata_13        (wparallel_samples[13]     ),
    .odata_14        (wparallel_samples[14]     ),
    .odata_15        (wparallel_samples[15]     ),
    .odata_16        (wparallel_samples[16]     ),
    .odata_17        (wparallel_samples[17]     ),
    .odata_18        (wparallel_samples[18]     ),
    .odata_19        (wparallel_samples[19]     )
  );



  ////////////////////////////////////////////////////CORRELATOR////////////////////////////////////////////////////////
  //delays the new sample trigger signal
  always @(posedge crx_clk) begin
    if (rrx_rst) begin
      new_sample_trig_delay_1 <= 0;
    end else begin
      if (!erx_en) begin
        new_sample_trig_delay_1 <= 0;
      end else begin
        new_sample_trig_delay_1 <= wband_pass_sample_ready;
      end
    end
  end

  //Correlation of the received samples with all possible transmitted signals
  rx_correlator rx_correlator_0(
    .crx_clk           (crx_clk                ),  //clock signal
    .rrx_rst           (rrx_rst                ),  //reset signal
    .erx_en            (erx_en                 ),  //enable signal

    .inew_sample_trig  (new_sample_trig_delay_1),  //new sample trigger

    //20 samples in parallel
    .idata_sample_0    (wparallel_samples[0]   ),
    .idata_sample_1    (wparallel_samples[1]   ),
    .idata_sample_2    (wparallel_samples[2]   ),
    .idata_sample_3    (wparallel_samples[3]   ),
    .idata_sample_4    (wparallel_samples[4]   ),
    .idata_sample_5    (wparallel_samples[5]   ),
    .idata_sample_6    (wparallel_samples[6]   ),
    .idata_sample_7    (wparallel_samples[7]   ),
    .idata_sample_8    (wparallel_samples[8]   ),
    .idata_sample_9    (wparallel_samples[9]   ),
    .idata_sample_10   (wparallel_samples[10]  ),
    .idata_sample_11   (wparallel_samples[11]  ),
    .idata_sample_12   (wparallel_samples[12]  ),
    .idata_sample_13   (wparallel_samples[13]  ),
    .idata_sample_14   (wparallel_samples[14]  ),
    .idata_sample_15   (wparallel_samples[15]  ),
    .idata_sample_16   (wparallel_samples[16]  ),
    .idata_sample_17   (wparallel_samples[17]  ),
    .idata_sample_18   (wparallel_samples[18]  ),
    .idata_sample_19   (wparallel_samples[19]  ),


    //result of the correlation for the 16 possible pseudo-random binary sequences
    .ocorrelation_seq_0 (wcorrelation_result[0] ),
    .ocorrelation_seq_1 (wcorrelation_result[1] ),
    .ocorrelation_seq_2 (wcorrelation_result[2] ),
    .ocorrelation_seq_3 (wcorrelation_result[3] ),
    .ocorrelation_seq_4 (wcorrelation_result[4] ),
    .ocorrelation_seq_5 (wcorrelation_result[5] ),
    .ocorrelation_seq_6 (wcorrelation_result[6] ),
    .ocorrelation_seq_7 (wcorrelation_result[7] ),
    .ocorrelation_seq_8 (wcorrelation_result[8] ),
    .ocorrelation_seq_9 (wcorrelation_result[9] ),
    .ocorrelation_seq_10(wcorrelation_result[10]),
    .ocorrelation_seq_11(wcorrelation_result[11]),
    .ocorrelation_seq_12(wcorrelation_result[12]),
    .ocorrelation_seq_13(wcorrelation_result[13]),
    .ocorrelation_seq_14(wcorrelation_result[14]),
    .ocorrelation_seq_15(wcorrelation_result[15]),
    .onew_result_trigger(wcorrelator_trigger    )
  );



  ///////////////////////////////////////////////////PEAK_FINDER////////////////////////////////////////////////////////
  always @(posedge crx_clk) begin
    if (rrx_rst) begin
      rfiltered_sample_band_pass <= 0;
    end else begin
      if (!erx_en) begin
        rfiltered_sample_band_pass <= 0;
      end else begin
        if (wband_pass_sample_ready) begin
          rfiltered_sample_band_pass <= wfiltered_sample_band_pass;
        end
      end
    end
  end
  
  rx_peak_identification rx_peak_identification_0(
  .crx_clk               (crx_clk                   ),  //clock signal
  .rrx_rst               (rrx_rst                   ),  //reset signal
  .erx_en                (erx_en                    ),  //enable signal

  .icurrent_time         (23                        ), 
   
  .isample_filtered      (rfiltered_sample_band_pass),  //output of band_pass filter
  
  .inew_samle_trigger    (wcorrelator_trigger       ),

  .isample_correlation_0 (wcorrelation_result[0]    ),
  .isample_correlation_1 (wcorrelation_result[1]    ),
  .isample_correlation_2 (wcorrelation_result[2]    ),
  .isample_correlation_3 (wcorrelation_result[3]    ),
  .isample_correlation_4 (wcorrelation_result[4]    ),
  .isample_correlation_5 (wcorrelation_result[5]    ),
  .isample_correlation_6 (wcorrelation_result[6]    ),
  .isample_correlation_7 (wcorrelation_result[7]    ),
  .isample_correlation_8 (wcorrelation_result[8]    ),
  .isample_correlation_9 (wcorrelation_result[9]    ),
  .isample_correlation_10(wcorrelation_result[10]   ),
  .isample_correlation_11(wcorrelation_result[11]   ),
  .isample_correlation_12(wcorrelation_result[12]   ),
  .isample_correlation_13(wcorrelation_result[13]   ),
  .isample_correlation_14(wcorrelation_result[14]   ),
  .isample_correlation_15(wcorrelation_result[15]   ),

  .o_sample_arm          (o_sample_arm              ),  //Peak Value
  .o_received_seq        (o_received_seq            ),
  .o_time_arm            (o_time_arm                ),  //Timestamp
  .o_trigger_arm         (o_trigger_arm             )   //Trigger
  );
  
endmodule


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
*                                                                             *
*              @Copyright (C) 2018, #1Nadal, All Rights Reserved              *
*                                                                             *
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
