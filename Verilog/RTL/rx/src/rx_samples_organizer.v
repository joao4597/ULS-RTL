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
 */

module rx_samples_organizer(
  input  wire               crx_clk         ,  //clock signal
  input  wire               rrx_rst         ,  //reset signal
  input  wire               erx_en          ,  //enable signal
  input  wire signed [15:0] idata_in_RAM    ,  //new sample to be stored
  
  input  wire               inew_sample_trig,  //new sample triger
 
  //20 signed consecutive samples in parallel 
  output wire signed [15:0] odata_0         ,  
  output wire signed [15:0] odata_1         ,
  output wire signed [15:0] odata_2         ,
  output wire signed [15:0] odata_3         ,
  output wire signed [15:0] odata_4         ,
  output wire signed [15:0] odata_5         ,
  output wire signed [15:0] odata_6         ,
  output wire signed [15:0] odata_7         ,
  output wire signed [15:0] odata_8         ,
  output wire signed [15:0] odata_9         ,
  output wire signed [15:0] odata_10        ,
  output wire signed [15:0] odata_11        ,
  output wire signed [15:0] odata_12        ,
  output wire signed [15:0] odata_13        ,
  output wire signed [15:0] odata_14        ,
  output wire signed [15:0] odata_15        ,
  output wire signed [15:0] odata_16        ,
  output wire signed [15:0] odata_17        ,
  output wire signed [15:0] odata_18        ,
  output wire signed [15:0] odata_19                     
  );

  wire signed [15:0] wsamples_out [19:0];
  wire [4:0] order;
  
  reg [4:0] rram_cycle_counter;
  
  //Keeps track of what ram out of the 20, the sample is being writen to
  always @(posedge crx_clk) begin
    if (rrx_rst == 1) begin
      rram_cycle_counter <= 0;
    end else begin
      if (inew_sample_trig) begin
        if (rram_cycle_counter >= 19) begin
          rram_cycle_counter <= 0;
        end else begin
          rram_cycle_counter <= rram_cycle_counter + 1;
        end
      end
    end
  end
    
  
  rx_BRAM_internal_controller #(
      .MEMORY_LENGTH(510)
    )
    rx_BRAM_internal_controller_0 (
      .crx_clk         (crx_clk                                      ),
      .rrx_rst         (rrx_rst                                      ),
      .erx_en          (erx_en                                       ),
      
      .new_sample_trig (inew_sample_trig                             ),
      .wr_en_RAM       ((rram_cycle_counter == 0) && inew_sample_trig),
      .data_in_RAM     (idata_in_RAM                                 ),
                                   
      .data_out_RAM    (wsamples_out[0]                              )
    );
  
  
  rx_BRAM_internal_controller #(
      .MEMORY_LENGTH(510)
    )
    rx_BRAM_internal_controller_1 (
      .crx_clk         (crx_clk                                      ),
      .rrx_rst         (rrx_rst                                      ),
      .erx_en          (erx_en                                       ),
      
      .new_sample_trig (inew_sample_trig                             ),
      .wr_en_RAM       ((rram_cycle_counter == 1) && inew_sample_trig),
      .data_in_RAM     (idata_in_RAM                                 ),
                                   
      .data_out_RAM    (wsamples_out[1]                              )
    );
  
  
  rx_BRAM_internal_controller #(
      .MEMORY_LENGTH(510)
    )
    rx_BRAM_internal_controller_2 (
      .crx_clk         (crx_clk                                      ),
      .rrx_rst         (rrx_rst                                      ),
      .erx_en          (erx_en                                       ),
      
      .new_sample_trig (inew_sample_trig                             ),
      .wr_en_RAM       ((rram_cycle_counter == 2) && inew_sample_trig),
      .data_in_RAM     (idata_in_RAM                                 ),
                                   
      .data_out_RAM    (wsamples_out[2]                              )
    );
  
  
  rx_BRAM_internal_controller #(
      .MEMORY_LENGTH(510)
    )
    rx_BRAM_internal_controller_3 (
      .crx_clk         (crx_clk                                      ),
      .rrx_rst         (rrx_rst                                      ),
      .erx_en          (erx_en                                       ),
      
      .new_sample_trig (inew_sample_trig                             ),
      .wr_en_RAM       ((rram_cycle_counter == 3) && inew_sample_trig),
      .data_in_RAM     (idata_in_RAM                                 ),
                                   
      .data_out_RAM    (wsamples_out[3]                              )
    );
  
  
  rx_BRAM_internal_controller #(
      .MEMORY_LENGTH(510)
    )
    rx_BRAM_internal_controller_4 (
      .crx_clk         (crx_clk                                      ),
      .rrx_rst         (rrx_rst                                      ),
      .erx_en          (erx_en                                       ),
      
      .new_sample_trig (inew_sample_trig                             ),
      .wr_en_RAM       ((rram_cycle_counter == 4) && inew_sample_trig),
      .data_in_RAM     (idata_in_RAM                                 ),
                                   
      .data_out_RAM    (wsamples_out[4]                              )
    );
  
  
  rx_BRAM_internal_controller #(
      .MEMORY_LENGTH(510)
    )
    rx_BRAM_internal_controller_5 (
      .crx_clk         (crx_clk                                      ),
      .rrx_rst         (rrx_rst                                      ),
      .erx_en          (erx_en                                       ),
      
      .new_sample_trig (inew_sample_trig                             ),
      .wr_en_RAM       ((rram_cycle_counter == 5) && inew_sample_trig),
      .data_in_RAM     (idata_in_RAM                                 ),
                                   
      .data_out_RAM    (wsamples_out[5]                              )
    );
  
  
  rx_BRAM_internal_controller #(
      .MEMORY_LENGTH(510)
    )
    rx_BRAM_internal_controller_6 (
      .crx_clk         (crx_clk                                      ),
      .rrx_rst         (rrx_rst                                      ),
      .erx_en          (erx_en                                       ),
      
      .new_sample_trig (inew_sample_trig                             ),
      .wr_en_RAM       ((rram_cycle_counter == 6) && inew_sample_trig),
      .data_in_RAM     (idata_in_RAM                                 ),
                                   
      .data_out_RAM    (wsamples_out[6]                              )
    );
  
  
  rx_BRAM_internal_controller #(
      .MEMORY_LENGTH(510)
    )
    rx_BRAM_internal_controller_7 (
      .crx_clk         (crx_clk                                      ),
      .rrx_rst         (rrx_rst                                      ),
      .erx_en          (erx_en                                       ),
      
      .new_sample_trig (inew_sample_trig                             ),
      .wr_en_RAM       ((rram_cycle_counter == 7) && inew_sample_trig),
      .data_in_RAM     (idata_in_RAM                                 ),
                                   
      .data_out_RAM    (wsamples_out[7]                              )
    );
  
  
  rx_BRAM_internal_controller #(
      .MEMORY_LENGTH(510)
    )
    rx_BRAM_internal_controller_8 (
      .crx_clk         (crx_clk                                      ),
      .rrx_rst         (rrx_rst                                      ),
      .erx_en          (erx_en                                       ),
      
      .new_sample_trig (inew_sample_trig                             ),
      .wr_en_RAM       ((rram_cycle_counter == 8) && inew_sample_trig),
      .data_in_RAM     (idata_in_RAM                                 ),
                                   
      .data_out_RAM    (wsamples_out[8]                              )
    );
  
  
  rx_BRAM_internal_controller #(
      .MEMORY_LENGTH(510)
    )
    rx_BRAM_internal_controller_9 (
      .crx_clk         (crx_clk                                      ),
      .rrx_rst         (rrx_rst                                      ),
      .erx_en          (erx_en                                       ),
      
      .new_sample_trig (inew_sample_trig                             ),
      .wr_en_RAM       ((rram_cycle_counter == 9) && inew_sample_trig),
      .data_in_RAM     (idata_in_RAM                                 ),
                                   
      .data_out_RAM    (wsamples_out[9]                              )
    );
  
  
  rx_BRAM_internal_controller #(
      .MEMORY_LENGTH(510)
    )
    rx_BRAM_internal_controller_10 (
      .crx_clk         (crx_clk                                       ),
      .rrx_rst         (rrx_rst                                       ),
      .erx_en          (erx_en                                        ),
      
      .new_sample_trig (inew_sample_trig                              ),
      .wr_en_RAM       ((rram_cycle_counter == 10) && inew_sample_trig),
      .data_in_RAM     (idata_in_RAM                                  ),
                                   
      .data_out_RAM    (wsamples_out[10        ]                      )
    );
  
  
  rx_BRAM_internal_controller #(
      .MEMORY_LENGTH(510)
    )
    rx_BRAM_internal_controller_11 (
      .crx_clk         (crx_clk                                       ),
      .rrx_rst         (rrx_rst                                       ),
      .erx_en          (erx_en                                        ),
      
      .new_sample_trig (inew_sample_trig                              ),
      .wr_en_RAM       ((rram_cycle_counter == 11) && inew_sample_trig),
      .data_in_RAM     (idata_in_RAM                                  ),
                                   
      .data_out_RAM    (wsamples_out[11        ]                      )
    );
  
  
  rx_BRAM_internal_controller #(
      .MEMORY_LENGTH(510)
    )
    rx_BRAM_internal_controller_12 (
      .crx_clk         (crx_clk                                       ),
      .rrx_rst         (rrx_rst                                       ),
      .erx_en          (erx_en                                        ),
      
      .new_sample_trig (inew_sample_trig                              ),
      .wr_en_RAM       ((rram_cycle_counter == 12) && inew_sample_trig),
      .data_in_RAM     (idata_in_RAM                                  ),
                                   
      .data_out_RAM    (wsamples_out[12        ]                      )
    );
  
  
  rx_BRAM_internal_controller #(
      .MEMORY_LENGTH(510)
    )
    rx_BRAM_internal_controller_13 (
      .crx_clk         (crx_clk                                       ),
      .rrx_rst         (rrx_rst                                       ),
      .erx_en          (erx_en                                        ),
      
      .new_sample_trig (inew_sample_trig                              ), 
      .wr_en_RAM       ((rram_cycle_counter == 13) && inew_sample_trig),
      .data_in_RAM     (idata_in_RAM                                  ),
                                   
      .data_out_RAM    (wsamples_out[13        ]                      )
    );
  
  
  rx_BRAM_internal_controller #(
      .MEMORY_LENGTH(510)
    )
    rx_BRAM_internal_controller_14 (
      .crx_clk         (crx_clk                                       ),
      .rrx_rst         (rrx_rst                                       ),
      .erx_en          (erx_en                                        ),
      
      .new_sample_trig (inew_sample_trig                              ),
      .wr_en_RAM       ((rram_cycle_counter == 14) && inew_sample_trig),
      .data_in_RAM     (idata_in_RAM                                  ),
                                   
      .data_out_RAM    (wsamples_out[14        ]                      )
    );
  
  
  rx_BRAM_internal_controller #(
      .MEMORY_LENGTH(510)
    )
    rx_BRAM_internal_controller_15 (
      .crx_clk         (crx_clk                                       ),
      .rrx_rst         (rrx_rst                                       ),
      .erx_en          (erx_en                                        ),
      
      .new_sample_trig (inew_sample_trig                              ),
      .wr_en_RAM       ((rram_cycle_counter == 15) && inew_sample_trig),
      .data_in_RAM     (idata_in_RAM                                  ),
                                   
      .data_out_RAM    (wsamples_out[15        ]                      )
    );
  
  
  rx_BRAM_internal_controller #(
      .MEMORY_LENGTH(510)
    )
    rx_BRAM_internal_controller_16 (
      .crx_clk         (crx_clk                                       ),
      .rrx_rst         (rrx_rst                                       ),
      .erx_en          (erx_en                                        ),
      
      .new_sample_trig (inew_sample_trig                              ),
      .wr_en_RAM       ((rram_cycle_counter == 16) && inew_sample_trig),
      .data_in_RAM     (idata_in_RAM                                  ),
                                   
      .data_out_RAM    (wsamples_out[16        ]                      )
    );
  
  
  rx_BRAM_internal_controller #(
      .MEMORY_LENGTH(510)
    )
    rx_BRAM_internal_controller_17 (
      .crx_clk         (crx_clk                                       ),
      .rrx_rst         (rrx_rst                                       ),
      .erx_en          (erx_en                                        ),
      
      .new_sample_trig (inew_sample_trig                              ),
      .wr_en_RAM       ((rram_cycle_counter == 17) && inew_sample_trig),
      .data_in_RAM     (idata_in_RAM                                  ),
                                   
      .data_out_RAM    (wsamples_out[17        ]                      )
    );
  
  
  rx_BRAM_internal_controller #(
      .MEMORY_LENGTH(510)
    )
    rx_BRAM_internal_controller_18 (
      .crx_clk         (crx_clk                                       ),
      .rrx_rst         (rrx_rst                                       ),
      .erx_en          (erx_en                                        ),
      
      .new_sample_trig (inew_sample_trig                              ),
      .wr_en_RAM       ((rram_cycle_counter == 18) && inew_sample_trig),
      .data_in_RAM     (idata_in_RAM                                  ),
                                   
      .data_out_RAM    (wsamples_out[18        ]                      )
    );
  
  
  rx_BRAM_internal_controller #(
      .MEMORY_LENGTH(510)
    )
    rx_BRAM_internal_controller_19 (
      .crx_clk         (crx_clk                                       ),
      .rrx_rst         (rrx_rst                                       ),
      .erx_en          (erx_en                                        ),
      
      .new_sample_trig (inew_sample_trig                              ),
      .wr_en_RAM       ((rram_cycle_counter == 19) && inew_sample_trig),
      .data_in_RAM     (idata_in_RAM                                  ),
                                   
      .data_out_RAM    (wsamples_out[19        ]                      )
    );
  
  
  assign odata_0  = wsamples_out[0] ;
  assign odata_1  = wsamples_out[1] ;
  assign odata_2  = wsamples_out[2] ;
  assign odata_3  = wsamples_out[3] ;
  assign odata_4  = wsamples_out[4] ;
  assign odata_5  = wsamples_out[5] ;
  assign odata_6  = wsamples_out[6] ;
  assign odata_7  = wsamples_out[7] ;
  assign odata_8  = wsamples_out[8] ;
  assign odata_9  = wsamples_out[9] ;
  assign odata_10 = wsamples_out[10];
  assign odata_11 = wsamples_out[11];
  assign odata_12 = wsamples_out[12];
  assign odata_13 = wsamples_out[13];
  assign odata_14 = wsamples_out[14];
  assign odata_15 = wsamples_out[15];
  assign odata_16 = wsamples_out[16];
  assign odata_17 = wsamples_out[17];
  assign odata_18 = wsamples_out[18];
  assign odata_19 = wsamples_out[19];
  
  
endmodule 


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
*                                                                             *
*              @Copyright (C) 2018, #1Nadal, All Rights Reserved              *
*                                                                             *
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */