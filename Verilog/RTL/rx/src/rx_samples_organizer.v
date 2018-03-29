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

module rx_filter(
  input        wire crx_clk,
  input        wire rrx_rst,
  input        wire erx_en ,
  input signed wire [15:0] idata_in_RAM,
 
  input        wire inew_sample_trig
  );

wire signed [15:0] wsamples_out [19:0];

rx_self_controled_BRAM rx_self_controled_BRAM_0 #(
    .MEMORY_INDEX = 0,
    .MEMORY_LENGTH = 510
  )
  (
    .crx_clk         (crx_clk         ),
    .rrx_rst         (rrx_rst         ),
    .erx_en          (erx_en          ),
    .inew_sample_trig(inew_sample_trig),
    
    .data_in_RAM     (idata_in_RAM    ),
    
    .data_out_RAM    (wsamples_out[0])
  );

rx_self_controled_BRAM rx_self_controled_BRAM_1 #(
    .MEMORY_INDEX = 0,
    .MEMORY_LENGTH = 510
  )
  (
    .crx_clk         (crx_clk         ),
    .rrx_rst         (rrx_rst         ),
    .erx_en          (erx_en          ),
    .inew_sample_trig(inew_sample_trig),
    
    .data_in_RAM     (idata_in_RAM    ),
    
    .data_out_RAM    (wsamples_out[1])
  );

rx_self_controled_BRAM rx_self_controled_BRAM_2 #(
    .MEMORY_INDEX = 0,
    .MEMORY_LENGTH = 510
  )
  (
    .crx_clk         (crx_clk         ),
    .rrx_rst         (rrx_rst         ),
    .erx_en          (erx_en          ),
    .inew_sample_trig(inew_sample_trig),
    
    .data_in_RAM     (idata_in_RAM    ),
    
    .data_out_RAM    (wsamples_out[2])
  );

rx_self_controled_BRAM rx_self_controled_BRAM_3 #(
    .MEMORY_INDEX = 0,
    .MEMORY_LENGTH = 510
  )
  (
    .crx_clk         (crx_clk         ),
    .rrx_rst         (rrx_rst         ),
    .erx_en          (erx_en          ),
    .inew_sample_trig(inew_sample_trig),
    
    .data_in_RAM     (idata_in_RAM    ),
    
    .data_out_RAM    (wsamples_out[3])
  );

rx_self_controled_BRAM rx_self_controled_BRAM_4 #(
    .MEMORY_INDEX = 0,
    .MEMORY_LENGTH = 510
  )
  (
    .crx_clk         (crx_clk         ),
    .rrx_rst         (rrx_rst         ),
    .erx_en          (erx_en          ),
    .inew_sample_trig(inew_sample_trig),
    
    .data_in_RAM     (idata_in_RAM    ),
    
    .data_out_RAM    (wsamples_out[4])
  );

rx_self_controled_BRAM rx_self_controled_BRAM_5 #(
    .MEMORY_INDEX = 0,
    .MEMORY_LENGTH = 510
  )
  (
    .crx_clk         (crx_clk         ),
    .rrx_rst         (rrx_rst         ),
    .erx_en          (erx_en          ),
    .inew_sample_trig(inew_sample_trig),
    
    .data_in_RAM     (idata_in_RAM    ),
    
    .data_out_RAM    (wsamples_out[5])
  );

rx_self_controled_BRAM rx_self_controled_BRAM_6 #(
    .MEMORY_INDEX = 0,
    .MEMORY_LENGTH = 510
  )
  (
    .crx_clk         (crx_clk         ),
    .rrx_rst         (rrx_rst         ),
    .erx_en          (erx_en          ),
    .inew_sample_trig(inew_sample_trig),
    
    .data_in_RAM     (idata_in_RAM    ),
    
    .data_out_RAM    (wsamples_out[6])
  );

rx_self_controled_BRAM rx_self_controled_BRAM_7 #(
    .MEMORY_INDEX = 0,
    .MEMORY_LENGTH = 510
  )
  (
    .crx_clk         (crx_clk         ),
    .rrx_rst         (rrx_rst         ),
    .erx_en          (erx_en          ),
    .inew_sample_trig(inew_sample_trig),
    
    .data_in_RAM     (idata_in_RAM    ),
    
    .data_out_RAM    (wsamples_out[7])
  );

rx_self_controled_BRAM rx_self_controled_BRAM_8 #(
    .MEMORY_INDEX = 0,
    .MEMORY_LENGTH = 510
  )
  (
    .crx_clk         (crx_clk         ),
    .rrx_rst         (rrx_rst         ),
    .erx_en          (erx_en          ),
    .inew_sample_trig(inew_sample_trig),
    
    .data_in_RAM     (idata_in_RAM    ),
    
    .data_out_RAM    (wsamples_out[8])
  );

rx_self_controled_BRAM rx_self_controled_BRAM_9 #(
    .MEMORY_INDEX = 0,
    .MEMORY_LENGTH = 510
  )
  (
    .crx_clk         (crx_clk         ),
    .rrx_rst         (rrx_rst         ),
    .erx_en          (erx_en          ),
    .inew_sample_trig(inew_sample_trig),
    
    .data_in_RAM     (idata_in_RAM    ),
    
    .data_out_RAM    (wsamples_out[9])
  );

rx_self_controled_BRAM rx_self_controled_BRAM_10 #(
    .MEMORY_INDEX = 0,
    .MEMORY_LENGTH = 510
  )
  (
    .crx_clk         (crx_clk         ),
    .rrx_rst         (rrx_rst         ),
    .erx_en          (erx_en          ),
    .inew_sample_trig(inew_sample_trig),
    
    .data_in_RAM     (idata_in_RAM    ),
    
    .data_out_RAM    (wsamples_out[10])
  );

rx_self_controled_BRAM rx_self_controled_BRAM_11 #(
    .MEMORY_INDEX = 0,
    .MEMORY_LENGTH = 510
  )
  (
    .crx_clk         (crx_clk         ),
    .rrx_rst         (rrx_rst         ),
    .erx_en          (erx_en          ),
    .inew_sample_trig(inew_sample_trig),
    
    .data_in_RAM     (idata_in_RAM    ),
    
    .data_out_RAM    (wsamples_out[11])
  );

rx_self_controled_BRAM rx_self_controled_BRAM_12 #(
    .MEMORY_INDEX = 0,
    .MEMORY_LENGTH = 510
  )
  (
    .crx_clk         (crx_clk         ),
    .rrx_rst         (rrx_rst         ),
    .erx_en          (erx_en          ),
    .inew_sample_trig(inew_sample_trig),
    
    .data_in_RAM     (idata_in_RAM    ),
    
    .data_out_RAM    (wsamples_out[12])
  );

rx_self_controled_BRAM rx_self_controled_BRAM_13 #(
    .MEMORY_INDEX = 0,
    .MEMORY_LENGTH = 510
  )
  (
    .crx_clk         (crx_clk         ),
    .rrx_rst         (rrx_rst         ),
    .erx_en          (erx_en          ),
    .inew_sample_trig(inew_sample_trig),
    
    .data_in_RAM     (idata_in_RAM    ),
    
    .data_out_RAM    (wsamples_out[13])
  );

rx_self_controled_BRAM rx_self_controled_BRAM_14 #(
    .MEMORY_INDEX = 0,
    .MEMORY_LENGTH = 510
  )
  (
    .crx_clk         (crx_clk         ),
    .rrx_rst         (rrx_rst         ),
    .erx_en          (erx_en          ),
    .inew_sample_trig(inew_sample_trig),
    
    .data_in_RAM     (idata_in_RAM    ),
    
    .data_out_RAM    (wsamples_out[14])
  );

rx_self_controled_BRAM rx_self_controled_BRAM_15 #(
    .MEMORY_INDEX = 0,
    .MEMORY_LENGTH = 510
  )
  (
    .crx_clk         (crx_clk         ),
    .rrx_rst         (rrx_rst         ),
    .erx_en          (erx_en          ),
    .inew_sample_trig(inew_sample_trig),
    
    .data_in_RAM     (idata_in_RAM    ),
    
    .data_out_RAM    (wsamples_out[15])
  );

rx_self_controled_BRAM rx_self_controled_BRAM_16 #(
    .MEMORY_INDEX = 0,
    .MEMORY_LENGTH = 510
  )
  (
    .crx_clk         (crx_clk         ),
    .rrx_rst         (rrx_rst         ),
    .erx_en          (erx_en          ),
    .inew_sample_trig(inew_sample_trig),
    
    .data_in_RAM     (idata_in_RAM    ),
    
    .data_out_RAM    (wsamples_out[16])
  );

rx_self_controled_BRAM rx_self_controled_BRAM_17 #(
    .MEMORY_INDEX = 0,
    .MEMORY_LENGTH = 510
  )
  (
    .crx_clk         (crx_clk         ),
    .rrx_rst         (rrx_rst         ),
    .erx_en          (erx_en          ),
    .inew_sample_trig(inew_sample_trig),
    
    .data_in_RAM     (idata_in_RAM    ),
    
    .data_out_RAM    (wsamples_out[17])
  );

rx_self_controled_BRAM rx_self_controled_BRAM_18 #(
    .MEMORY_INDEX = 0,
    .MEMORY_LENGTH = 510
  )
  (
    .crx_clk         (crx_clk         ),
    .rrx_rst         (rrx_rst         ),
    .erx_en          (erx_en          ),
    .inew_sample_trig(inew_sample_trig),
    
    .data_in_RAM     (idata_in_RAM    ),
    
    .data_out_RAM    (wsamples_out[18])
  );

rx_self_controled_BRAM rx_self_controled_BRAM_19 #(
    .MEMORY_INDEX = 0,
    .MEMORY_LENGTH = 510
  )
  (
    .crx_clk         (crx_clk         ),
    .rrx_rst         (rrx_rst         ),
    .erx_en          (erx_en          ),
    .inew_sample_trig(inew_sample_trig),
    
    .data_in_RAM     (idata_in_RAM    ),
    
    .data_out_RAM    (wsamples_out[19])
  );
 

endmodule 


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
*                                                                             *
*              @Copyright (C) 2018, #1Nadal, All Rights Reserved              *
*                                                                             *
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */