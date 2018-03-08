/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
* tx_modulation.v v0.00                                                       *
*                                                                             *
* @Author  Joao Miguel Fernandes Magalhaes                                    *
* @Contact up201305379@fe.up.fe                                               *
* @Date    05/03/2018 18:31:43 GMT                                            *
*                                                                             *
* This part of code is written in Verilog hardware description language (HDL).*
* Please visit http://en.wikipedia.org/wiki/Verilog (or some proper source)   *
* for more details on the language used herein.                               *
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


/**
 * GENERAL DESCRIPTION:
 * 
 * This module takes a two dimentional vector containing an array of pseudo-random binary sequences
 * generates a square signal modulated in BPSK by one of the binary sequences, the binary sequence 
 * to be modulated is selected by on of the inputs.
 */


`define CpP   8     //number of clocks per signal period
`define CpPRS 4     //Clock counter register size
`define PpB   5     //number of signal periods per bit
`define PpBRS 4     //Periode counter register size
`define SL    1024  //pseudo-random binary sequece length **
`define SLRS  11    //Sequence length register size
`define NoS   64    //number of orthogonal sequences      **


module tx_modulator(

  input                      ctx_clk           ,  //clock
  input                      rtx_rst           ,  //reset
  input                      ienable           ,  //enable

  input                      istart_interrupt  ,  //signal to acquire sequence selector and sart modulation
  input         [`SL - 1:0]  ibinary_sequence  ,  //array containing the available pseudo-random binary sequences 

  output  wire               omodulation          //modulated signal
  );


  //Selected Binary sequence
  reg [`SL - 1:0]    rselected_sequence;

  //counters
  reg [`CpPRS - 1:0] rclocks_counter   ;
  reg [`PpBRS - 1:0] rperiodes_counter ;
  reg [`SLRS - 1:0]  rbit_counter      ;
 
 
  //Satate machine registers 
  reg [2:0]          STATE             ;
  reg [2:0]          NEXTSATE          ;
 
  //Satate Machine states 
  parameter INI   = 3'b000             ,
            S1    = 3'b001             ,
            S2    = 3'b010             ,
            S3    = 3'b011             ,
            S4    = 3'b100             ;
 
  parameter CpPb2 = `CpP / 2'd2        ;


  //State machine reset logic
  always @(posedge ctx_clk) begin
    if (rtx_rst) begin
      STATE <= INI;
    end else begin
      if (!ienable) begin
        STATE <= INI;
      end else begin
        STATE <= NEXTSATE;
      end
    end
  end

  //Next state logic
  always @* begin
    case (STATE)
      INI: begin  //Idle state
        if (istart_interrupt) begin
          NEXTSATE = S1;
        end else begin
          NEXTSATE = INI;
        end
      end
      S1: begin  //Aquire binary sequence
        NEXTSATE = S2;
      end
      S2: begin  //Count clocks
        if (rbit_counter == 1023 && rclocks_counter == 7 
          && rperiodes_counter == 4) begin
          NEXTSATE = INI;
        end else begin
          NEXTSATE = S2;
        end
      end
    endcase
  end

  //Output logic
  always @(posedge ctx_clk) begin
    if (rtx_rst) begin
      rselected_sequence <= 0;
      rclocks_counter    <= 0;
      rperiodes_counter  <= 0;
      rbit_counter       <= 0;
    end else begin 
      case (STATE) 
        INI: begin 
          rselected_sequence <= 0;
          rclocks_counter    <= 0;
          rperiodes_counter  <= 0;
          rbit_counter       <= 0;
        end
        S1: begin
          rselected_sequence <= ibinary_sequence;  //Acquire selected sequence
        end
        S2: begin
          if (rclocks_counter == 7 && rperiodes_counter == 4) begin
            rbit_counter = rbit_counter + 1                        ;
            rclocks_counter    <= 0                                ;
            rperiodes_counter  <= 0                                ;
            rselected_sequence <= rselected_sequence >> 1'b1       ; //shift selected sequence to the right
          end else begin
            if(rclocks_counter == 7) begin
              rclocks_counter   <= 0                               ;
              rperiodes_counter <= rperiodes_counter + 1           ;
              rselected_sequence[0] <= !rselected_sequence[0]      ;
            end else begin
              if(rclocks_counter == 3) begin
                rselected_sequence[0] <= !rselected_sequence[0]    ;
                rclocks_counter <= rclocks_counter + 1             ;
              end else begin
                rclocks_counter <= rclocks_counter + 1             ;
              end
            end
          end
        end
      endcase
    end
  end


  //Result of modulation is stored on the LSB of rselected_sequnce hence this assign
  assign omodulation = rselected_sequence[0];


endmodule


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
*                                                                             *
*              @Copyright (C) 2018, #1Nadal, All Rights Reserved              *
*                                                                             *
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */