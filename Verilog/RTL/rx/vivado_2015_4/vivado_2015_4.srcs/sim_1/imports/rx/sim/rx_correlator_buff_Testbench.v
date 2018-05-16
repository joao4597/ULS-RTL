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

module rx_correlator_buff_Testbench();

  wire signed clk;
  //wire signed [40:0] sample_out [16:0];

  reg reset, enable;

  //Clock generator for testing
  tx_clk tx_clk_0(
    .clk(clk)
  );

  reg signed [31:0] rsample_correlation;
  reg               trigger             ;
  reg [3:0]         rreceived_seq       ;
  reg               rstorage_wash       ;
  reg               rnext_sample_trigger;
  reg               rall_aquired_trigg  ;  
  wire  signed [31:0] wsample_out  ;         
  wire                woutupt_ready;       

  rx_correlator_buff rx_correlator_buff_0(  
  .crx_clk               (clk                ),  //clock signal
  .rrx_rst               (reset              ),  //reset signal
  .erx_en                (enable             ),  //enable signal

  .inew_samle_trigger    (trigger            ),

  .isample_correlation_0 (rsample_correlation),
  .isample_correlation_1 (rsample_correlation),
  .isample_correlation_2 (rsample_correlation),
  .isample_correlation_3 (rsample_correlation),
  .isample_correlation_4 (rsample_correlation),
  .isample_correlation_5 (rsample_correlation),
  .isample_correlation_6 (rsample_correlation),
  .isample_correlation_7 (rsample_correlation),
  .isample_correlation_8 (rsample_correlation),
  .isample_correlation_9 (rsample_correlation),
  .isample_correlation_10(rsample_correlation),
  .isample_correlation_11(rsample_correlation),
  .isample_correlation_12(rsample_correlation),
  .isample_correlation_13(rsample_correlation),
  .isample_correlation_14(rsample_correlation),
  .isample_correlation_15(rsample_correlation),

  .ireceived_seq         (rreceived_seq       ),
  .istorage_wash_enable  (rstorage_wash       ),
  .inext_sample_trigger  (rnext_sample_trigger),
  .iall_acquired_trigg   (rall_aquired_trigg  ),

  .ocorr_sample          (wsample_out         ),
  .ocorr_sample_ready    (woutupt_ready       )                

  );
/* 
wsample_out  ;      
woutupt_ready;      
*/

  //test
  integer i, q;
  initial begin
    rsample_correlation  = 0;
    trigger              = 0;
    rreceived_seq        = 0;
    rstorage_wash        = 0;
    rnext_sample_trigger = 0;
    rall_aquired_trigg   = 0;


    //open file to save modulation result
    samples_file = $fopen("..\\..\\..\\..\\sim_files\\corr_buffer\\corr_buffer_result.csv", "w");

    //reset module
    @(negedge clk);
    reset     <= 1'b1;
    enable    <= 1'b0;

    
    @(negedge clk);
    reset  <= 1'b0;
    enable <= 1'b1;


    for (i = 0; i < 1000; i = i + 1) begin
      rsample_correlation <= i;
      trigger = 1;
      @(negedge clk);
      trigger = 0;

      for (q = 0; q < 511; q = q + 1) begin
        @(negedge clk);
      end

    end

    for (i = 999; i > 0; i = i - 1) begin
      rsample_correlation <= i;
      trigger = 1;
      @(negedge clk);
      trigger = 0;

      for (q = 0; q < 511; q = q + 1) begin
        @(negedge clk);
      end
    end
    

    //after peak has been identified
    for (i = 0; i < 10000; i = i + 1) begin
      rsample_correlation <= i;
      trigger = 1;
      @(negedge clk);
      trigger = 0;

      for (q = 0; q < 511; q = q + 1) begin
        @(negedge clk);
      end
    end


    $finish;
  end


  integer i_2;
  integer samples_file;
  initial begin
    i_2 = 0;
    rreceived_seq        = 0;
    rstorage_wash        = 0;
    rnext_sample_trigger = 0;
    rall_aquired_trigg   = 0;


    //open file to save modulation result
    samples_file = $fopen("..\\..\\..\\..\\sim_files\\corr_buffer\\corr_buffer_result.csv", "w");


    for (i_2 = 0; i_2 < 2000 * 512; i_2 = i_2 + 1) begin
      @(negedge clk);
    end

    rreceived_seq        = 1;
    rstorage_wash        = 1;

    while (!woutupt_ready) begin
      @(negedge clk);
    end

    for (i_2 = 0; i_2 < 128; ) begin
      rnext_sample_trigger <= 0;
      if (woutupt_ready) begin
        $fwrite(samples_file, "%1d\n", $signed(wsample_out));
        $fflush(samples_file);
        rnext_sample_trigger <= 1;
        i_2 = i_2 + 1;
      end
      @(negedge clk);
    end
    

    rall_aquired_trigg <= 1;

    $finish;
  end


endmodule

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
*                                                                             *
*              @Copyright (C) 2018, #1Nadal, All Rights Reserved              *
*                                                                             *
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */