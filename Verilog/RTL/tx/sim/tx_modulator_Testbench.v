/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
* tx_modulator_Testbench.v v0.00                                              *
*                                                                             *
* @Author  Joao Miguel Fernandes Magalhaes                                    *
* @Contact up201305379@fe.up.fe                                               *
* @Date    06/03/2018 13:53:59 GMT                                            *
*                                                                             *
* This part of code is written in Verilog hardware description language (HDL).*
* Please visit http://en.wikipedia.org/wiki/Verilog (or some proper source)   *
* for more details on the language used herein.                               *
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


/**
* GENERAL DESCRIPTION:
*
* -Generates a random binary sequence
* -Sends start_interrupt to modulator
* -Saves the modulation result every clock to "modulation.txt"
**/


`timescale 1ns / 1ps

module tx_modulator_Testbench();

  reg [1023:0] binary_sequence;
  reg start_interrupt;
  reg enable;
  reg rst;

  wire clk;
  wire modulation;

  integer i;

  integer file        ;
  integer file_PRBS   ;
  integer file_correct;
  integer integer_aux ;
  integer caracters   ;
  integer integer_aux1;

  //Clock generator for testing
  tx_clk tx_clk_0(
    .clk(clk)
  );


  //Module under testing
  tx_modulator tx_modulator_0(
    .ctx_clk(clk),
    .rtx_rst(rst),
    .ienable(enable),

    .istart_interrupt(start_interrupt),
    .ibinary_sequence(binary_sequence),

    .omodulation(modulation)
  );

  initial begin

    file         = 0;
    file_PRBS    = 0;
    file_correct = 0;
    integer_aux  = 0;
    caracters    = 0;
    integer_aux1 = 0;

    //open file to save modulation result
    file = $fopen("..\\..\\..\\..\\sim_files\\modulation.txt", "w");
    //open file too read PRBS
    file_PRBS = $fopen("..\\..\\..\\..\\sim_files\\PRBS.txt", "r");
    //open file to save correct modulation result
    file_correct = $fopen("..\\..\\..\\..\\sim_files\\modulation_correct.txt", "w");

    //Reset modules
    @(negedge clk);
    enable          <= 1'b0;
    rst             <= 1'b1;
    start_interrupt <= 1'b0;
    binary_sequence <= 1024'd0;


    //Desable reset and enable module
    @(negedge clk);
    enable          <= 1'b1;
    rst             <= 1'b0;

    //Generate random binary sequence
    /*for(i = 31; i <= 1023; i = i + 32) begin
      binary_sequence[i-:31] <= $urandom;
    end*/
    //Acquire random binary sequence from file
    for(i = 0; i <= 1023; i = i + 1) begin
      caracters = $fscanf(file_PRBS, "%d\n", integer_aux);
      if(integer_aux == 1)begin
        binary_sequence[i] = 1'b1;
        $fwrite(file_correct, "1\n1\n1\n1\n0\n0\n0\n0\n");
        $fwrite(file_correct, "1\n1\n1\n1\n0\n0\n0\n0\n");
        $fwrite(file_correct, "1\n1\n1\n1\n0\n0\n0\n0\n");
        $fwrite(file_correct, "1\n1\n1\n1\n0\n0\n0\n0\n");
        $fwrite(file_correct, "1\n1\n1\n1\n0\n0\n0\n0\n");
      end else begin
        binary_sequence[i] = 1'b0;
        $fwrite(file_correct, "0\n0\n0\n0\n1\n1\n1\n1\n");
        $fwrite(file_correct, "0\n0\n0\n0\n1\n1\n1\n1\n");
        $fwrite(file_correct, "0\n0\n0\n0\n1\n1\n1\n1\n");
        $fwrite(file_correct, "0\n0\n0\n0\n1\n1\n1\n1\n");
        $fwrite(file_correct, "0\n0\n0\n0\n1\n1\n1\n1\n");
      end
    end

    //Satart modulation
    start_interrupt <= 1'b1;


    //wait for modulation to start
    @(negedge clk);

    start_interrupt <= 1'b0;


    //Wait for modulation to end
    for(i = 0; i < 40960; i = i + 1) begin
      @(negedge clk);
      $fwrite(file, "%b\n", modulation);
    end

    @(negedge clk);

    //close file
    $fclose(file);
    $fclose(file_PRBS);
    $fclose(file_correct);

    //open modulation result and correct modulation for comparation
    file = $fopen("..\\..\\..\\..\\sim_files\\modulation.txt", "r");
    file_correct = $fopen("..\\..\\..\\..\\sim_files\\modulation_correct.txt", "r");

    //read modulation output and correct modulation from files and compare them line by line
    for(i = 0; !$feof(file_correct) || !$feof(file); i = i + 1) begin
      $fscanf(file_correct, "%d\n", integer_aux);
      $fscanf(file, "%d\n", integer_aux1);
      if(integer_aux != integer_aux1) begin
        $display("ERROR FOUND WHEN COMPARING FILES, line -> %d\n", i + 1);
        //close file
        $fclose(file);
        $fclose(file_correct);
        $finish;
      end
    end

    //successful test
    $display("PASSED!! Congratulations!");

    //close file
    $fclose(file);
    $fclose(file_correct);


    $display("FINITO!");

    $finish;
  end

endmodule


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
*                                                                             *
*              @Copyright (C) 2018, #1Nadal, All Rights Reserved              *
*                                                                             *
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */