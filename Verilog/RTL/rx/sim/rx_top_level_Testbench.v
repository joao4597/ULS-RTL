/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
* rx_filter_Testbench.v v0.00                                                 *
*                                                                             *
* @Author  Joao Miguel Fernandes Magalhaes                                    *
* @Contact up201305379@fe.up.fe                                               *
* @Date    06/03/2018 13:52:54 GMT                                            *
*                                                                             *
* This part of code is written in Verilog hardware description language (HDL).*
* Please visit http://en.wikipedia.org/wiki/Verilog (or some proper source)   *
* for more details on the language used herein.                               *
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


/**
* GENERAL DESCRIPTION:
*
* - This block exists for the porpose of testing the rx_top_level module
* 
**/


`timescale 1ns / 1ps

module rx_top_level_Testbench();

  wire signed clk;
  //wire signed [40:0] sample_out [16:0];

  reg reset, enable;
  reg signed [15:0] sample_in;
  reg               trigger  ;
  //Clock generator for testing
  tx_clk tx_clk_0(
    .clk(clk)
  );

  wire signed [40:0] sample_arm     ;
  wire         [3:0] received_signal;
  wire        [15:0] time_arm       ;
  wire               trigger_arm    ; 
  

  //block uder testing
  rx_top_level rx_top_level_0(
  .crx_clk        (clk           ),  //clock signal
  .rrx_rst        (reset         ),  //reset signal
  .erx_en         (enable        ),  //enable signal
       
  .inew_sample    (sample_in     ),

  .o_sample_arm   (sample_arm     ),  //Peak Value
  .o_received_seq (received_signal),
  .o_time_arm     (time_arm       ),  //Timestamp
  .o_trigger_arm  (trigger_arm    )   //Trigger
  );


  integer i, j, w              ;
  integer samples_file         ;
  integer low_pass_result      ; 
  integer band_pass_result     ;
  integer aux                  ;
  integer sample_aux           ;

  reg signed [15:0] aux_reg;
  reg [1:0] two_bit_counter;

  //test
  initial begin

    two_bit_counter <= 0;

    //open file to save modulation result
    samples_file     = $fopen("..\\..\\..\\..\\sim_files\\seq_11_12_13_14\\record_11_12_13_14.csv", "r");
    low_pass_result  = $fopen("..\\..\\..\\..\\sim_files\\seq_11_12_13_14\\low_pass_result.csv" , "w");
    band_pass_result = $fopen("..\\..\\..\\..\\sim_files\\seq_11_12_13_14\\band_pass_result.csv", "w");

    //reset module
    @(negedge clk);
    reset     <= 1'b1;
    enable    <= 1'b0;
    sample_in <= 1'b0;

    
    @(negedge clk);
    reset  <= 1'b0;
    enable <= 1'b1;


    for (i = 1, w = 1; $fscanf(samples_file, "%d\n", sample_aux) > 0;) begin

      sample_in <= sample_aux;
      

      //SAVE THE LOW_PASS RESULT
      @(negedge clk);
      $fwrite(low_pass_result, "%1d\n", $signed(rx_top_level_0.wfiltered_sample_low_pass));
      $fflush(low_pass_result);


      //SAVE THE BAND_PASS RESULT
      @(negedge clk);
      if (two_bit_counter == 0) begin
        $fwrite(band_pass_result, "%1d\n", $signed(rx_top_level_0.wfiltered_sample_band_pass));
        $fflush(band_pass_result);
        two_bit_counter = two_bit_counter + 1;
        i = i + 1;
        w = w + 1;
      end else begin
        two_bit_counter = two_bit_counter + 1;
      end

      //wait 127 clocks between new samples
      for (j = 0; j < 126; j = j + 1) begin
        @(negedge clk);
      end
    end


    $finish;
  end

  
  //SAVES THE RESULT OF RX_CORRELATOR
  integer correlator_result;
  integer correlator_result_mat;
  integer i_c;
  integer sample_aux_c;
  integer aux_c;
  initial begin

    i_c = 0;
    sample_aux_c = 0;

    //open file to save correlation result
    correlator_result     = $fopen("..\\..\\..\\..\\sim_files\\seq_11_12_13_14\\correlator_result.csv", "w");
    correlator_result_mat = $fopen("..\\..\\..\\..\\sim_files\\seq_11_12_13_14\\CORRELATOR_RESULT_MAT_12.csv", "r");;

    while (i_c > -1) begin
      @(negedge clk);
      if (rx_top_level_0.new_sample_trig_delay_1) begin
        @(negedge clk);
        @(negedge clk);
        $fwrite(correlator_result, "%1d\n", $signed(rx_top_level_0.wcorrelation_result[3]));
        $fflush(correlator_result);

        $fscanf(correlator_result_mat, "%d\n", sample_aux_c);
        aux_c = $signed(rx_top_level_0.wcorrelation_result[3]);
        
        if (sample_aux_c == aux_c) begin
          if (i_c % 200 == 0) begin
            //$display("%1d samples correct\n", i_c);
          end
        end else begin
          $display("%1d -> erro %1d -> %1d\n", i_c, sample_aux_c, aux_c);
          $finish;
        end

        i_c = i_c + 1;
      end
    end

    $finish;
  end



  //Saves the rx_peak_identification outputs
  initial begin
    @(negedge clk);
    while(1 == 1) begin
      @(negedge clk);
      if (trigger_arm) begin
        $display("++++++Peak Acquiered++++++"                   );
        $display("Sample value      -> %1d", $signed(sample_arm));
        $display("Timestamp         -> %1d", time_arm           );
        $display("Received sequence -> %1d", received_signal    );
        $display("++++++++++++++++++++++++++"                   );
      end   
    end
  end


endmodule

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
*                                                                             *
*              @Copyright (C) 2018, #1Nadal, All Rights Reserved              *
*                                                                             *
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */