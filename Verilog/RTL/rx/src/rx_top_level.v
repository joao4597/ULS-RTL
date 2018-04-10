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
  input  wire               crx_clk               ,  //clock signal
  input  wire               rrx_rst               ,  //reset signal
  input  wire               erx_en                ,  //enable signal

  input  wire signed [15:0] inew_sample           ,  //new sample in
  input  wire               inew_sample_trig      ,  //new sample trigger signal

  output wire signed [40:0] wcorrelation_result_0 ,
  output wire signed [40:0] wcorrelation_result_1 ,
  output wire signed [40:0] wcorrelation_result_2 ,
  output wire signed [40:0] wcorrelation_result_3 ,
  output wire signed [40:0] wcorrelation_result_4 ,
  output wire signed [40:0] wcorrelation_result_5 ,
  output wire signed [40:0] wcorrelation_result_6 ,
  output wire signed [40:0] wcorrelation_result_7 ,
  output wire signed [40:0] wcorrelation_result_8 ,
  output wire signed [40:0] wcorrelation_result_9 ,
  output wire signed [40:0] wcorrelation_result_10,
  output wire signed [40:0] wcorrelation_result_11,
  output wire signed [40:0] wcorrelation_result_12,
  output wire signed [40:0] wcorrelation_result_13,
  output wire signed [40:0] wcorrelation_result_14,
  output wire signed [40:0] wcorrelation_result_15

  );

  //Outputs of rx_low_pass_filter
  wire signed [15:0] wfiltered_sample_low_pass;

  //Outputs of rx_band_pass_filter
  wire signed [15:0] wfiltered_sample_band_pass;

  //
  reg inew_sample_trig_one_clock_delayed;

  wire signed [15:0] wparallel_samples [19:0];


  //Low pass filter
  rx_low_pass_filter rx_low_pass_filter_0(
  .crx_clk         (crx_clk                  ),  //clock signal
  .rrx_rst         (rrx_rst                  ),  //reset signal
  .erx_en          (erx_en                   ),  //enable signal
  .idata_in_RAM    (inew_sample              ),  //new sample to be stored

  .ofiltered_sample(wfiltered_sample_low_pass)
  );


  rx_band_pass_filter rx_band_pass_filter_0(
  .crx_clk         (crx_clk                   ),  //clock signal
  .rrx_rst         (rrx_rst                   ),  //reset signal
  .erx_en          (erx_en                    ),  //enable signal
  .idata_in_RAM    (wfiltered_sample_low_pass ),  //new sample to be stored

  .ofiltered_sample(wfiltered_sample_band_pass)
  );


  //stores incoming samples and outputs 20 of the stored samples every clock
  //in parallel
  rx_samples_organizer rx_samples_organizer_0(
    .crx_clk         (crx_clk                   ),  //clock signal
    .rrx_rst         (rrx_rst                   ),  //reset signal
    .erx_en          (erx_en                    ),  //enable signal
    .idata_in_RAM    (wfiltered_sample_band_pass),  //new sample to be stored

    .inew_sample_trig(inew_sample_trig          ),  //new sample trigger

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

  //buffer inew_sample_trig by one clock
  always @(posedge crx_clk) begin
    if (rrx_rst) begin
      inew_sample_trig_one_clock_delayed <= 0;
    end else begin
      if (!erx_en) begin
        inew_sample_trig_one_clock_delayed <= 0;
      end else begin
        inew_sample_trig_one_clock_delayed <= inew_sample_trig;
      end
    end
  end

  //Correlation of the received samples with all possible transmitted signals
  rx_correlator rx_correlator_0(
    .crx_clk           (crx_clk                           ),  //clock signal
    .rrx_rst           (rrx_rst                           ),  //reset signal
    .erx_en            (erx_en                            ),  //enable signal

    .inew_sample_trig  (inew_sample_trig_one_clock_delayed),  //new sample trigger

    //20 samples in parallel
    .idata_sample_0    (wparallel_samples[0]              ),
    .idata_sample_1    (wparallel_samples[1]              ),
    .idata_sample_2    (wparallel_samples[2]              ),
    .idata_sample_3    (wparallel_samples[3]              ),
    .idata_sample_4    (wparallel_samples[4]              ),
    .idata_sample_5    (wparallel_samples[5]              ),
    .idata_sample_6    (wparallel_samples[6]              ),
    .idata_sample_7    (wparallel_samples[7]              ),
    .idata_sample_8    (wparallel_samples[8]              ),
    .idata_sample_9    (wparallel_samples[9]              ),
    .idata_sample_10   (wparallel_samples[10]             ),
    .idata_sample_11   (wparallel_samples[11]             ),
    .idata_sample_12   (wparallel_samples[12]             ),
    .idata_sample_13   (wparallel_samples[13]             ),
    .idata_sample_14   (wparallel_samples[14]             ),
    .idata_sample_15   (wparallel_samples[15]             ),
    .idata_sample_16   (wparallel_samples[16]             ),
    .idata_sample_17   (wparallel_samples[17]             ),
    .idata_sample_18   (wparallel_samples[18]             ),
    .idata_sample_19   (wparallel_samples[19]             ),


    //result of the correlation for the 16 possible pseudo-random binary sequences
    .ocorrelation_seq_0 (wcorrelation_result_0            ),
    .ocorrelation_seq_1 (wcorrelation_result_1            ),
    .ocorrelation_seq_2 (wcorrelation_result_2            ),
    .ocorrelation_seq_3 (wcorrelation_result_3            ),
    .ocorrelation_seq_4 (wcorrelation_result_4            ),
    .ocorrelation_seq_5 (wcorrelation_result_5            ),
    .ocorrelation_seq_6 (wcorrelation_result_6            ),
    .ocorrelation_seq_7 (wcorrelation_result_7            ),
    .ocorrelation_seq_8 (wcorrelation_result_8            ),
    .ocorrelation_seq_9 (wcorrelation_result_9            ),
    .ocorrelation_seq_10(wcorrelation_result_10           ),
    .ocorrelation_seq_11(wcorrelation_result_11           ),
    .ocorrelation_seq_12(wcorrelation_result_12           ),
    .ocorrelation_seq_13(wcorrelation_result_13           ),
    .ocorrelation_seq_14(wcorrelation_result_14           ),
    .ocorrelation_seq_15(wcorrelation_result_15           )
  );

endmodule


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
*                                                                             *
*              @Copyright (C) 2018, #1Nadal, All Rights Reserved              *
*                                                                             *
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
