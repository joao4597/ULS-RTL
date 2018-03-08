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
 * -Receives as input a sample signaled by a triger
 * -Outputs a filtercoefficient selector
 * -Recceives the selected filter coefficient
 * -Outputs a filtered sample two clocks after receiving one as input
 * -The number of filter coefficients is parameterizable
 *
 * CONSTRAINTS:
 * -The number of clocks between two consecutive samples needs to be at least
 * equal to the FILTER_ORDER 
 */


`define FILTER_ORDER 200   //order of the filter being used
`define CB           16  //bist of filter Coefficient


module rx_filter(
  input                     crx_clk            , //rx clock
  input                     rrx_rst            , //rx reset signal
  input                     erx_en             , //module enable signal
           
  input      signed [15:0]  isample            , //samples to be filtered
  input                     inew_sample        , //new sample available
  input      signed [15:0]  ifilter_coefficient, //filter coefficient from memory
   
  output reg        [8:0]   oselect_coefficient, //selects the filter coefficient from the memory
  output reg signed [231:0] orsample           , //filtered samples
  output reg                osample_ready_trig   //new sample ready after filtering
  );

  reg         [((`FILTER_ORDER - 1) * 16) - 1:0] rsamples       ; //holds buffered isamples
  reg         [8:0]                              rcounter       ; //simple counter of executed multiplications
  reg                                            rtriger_buffer ; //buffers the osample_ready_triger one clock
  reg  signed [40:0]                             rsum           ; //sum of al multiplications of the filter coeff by the samples
  wire        [15:0]                             wheader_sample ; //sample to be placed at the head of the rsamples register
  wire signed [31:0]                             wmultiplication; //single multiplication of rsamples header by filter coeff

  //counter from 0 to `FILTER_ORDER
  always @(posedge crx_clk) begin
    if (rrx_rst) begin
      rcounter <= 0;
    end else begin
      if (!erx_en) begin
        rcounter <= 0;
      end else begin
        if (inew_sample) begin
          rcounter <= 0;
        end else begin
          if (rcounter < `FILTER_ORDER) begin
            rcounter <= rcounter + 1;
          end
        end
      end
    end
  end

  //determines whether the samples buffer rotates or a new sample is added to the head of the buffer
  assign wheader_sample = inew_sample ? isample : rsamples[15:0];

  //shift input samples accross register every clock
  always @(posedge crx_clk) begin
    if (rrx_rst) begin
      rsamples <= 0;
    end else begin
      if (!erx_en) begin
        rsamples <= 0;
      end else begin
        if ((rcounter < `FILTER_ORDER - 1) || inew_sample) begin
          rsamples[(((`FILTER_ORDER - 2) * 16) - 1):0]                <= rsamples[((`FILTER_ORDER - 1) * 16) - 1:16];
          rsamples[((`FILTER_ORDER - 1) * 16) - 1:((`FILTER_ORDER - 1) - 1) * 16] <= wheader_sample                 ;
        end
      end
    end
  end

  //selects filter coefficient from memory
  assign wmultiplication = $signed(rsamples[((`FILTER_ORDER - 1) * 16) - 1:((`FILTER_ORDER - 1) - 1) * 16]) * $signed(ifilter_coefficient);

  //multiplications adder
  always @(posedge crx_clk) begin
    if (rrx_rst) begin
      rsum <= 0;
    end else begin
      if (!erx_en) begin
        rsum <= 0;
      end else begin
        if (rcounter == 1) begin
          rsum <= wmultiplication;
        end else begin
          if (rcounter < `FILTER_ORDER) begin
            rsum <= rsum + wmultiplication;
          end
        end
      end
    end
  end

  //triger activated during one clock when new sample is ready after filtering
  always @(posedge crx_clk) begin
    if (rrx_rst) begin
      osample_ready_trig <= 0;
    end else begin
      if (!erx_en) begin
        osample_ready_trig <= 0;
      end else begin
        if (inew_sample) begin
          rtriger_buffer <= 1;
        end else begin
          if (rtriger_buffer) begin
            osample_ready_trig <= 1;
            rtriger_buffer <= 0;
          end else begin
            osample_ready_trig <= 0;
            rtriger_buffer <= 0;
          end
        end
      end
    end
  end

  //select filter coefficient
  always @(*) begin
    if (rcounter > 0) begin
      oselect_coefficient = rcounter - 1;
    end else begin
      if (rcounter == 0) begin
        oselect_coefficient = `FILTER_ORDER - 1;
      end
    end
     
  end

endmodule


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
*                                                                             *
*              @Copyright (C) 2018, #1Nadal, All Rights Reserved              *
*                                                                             *
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */