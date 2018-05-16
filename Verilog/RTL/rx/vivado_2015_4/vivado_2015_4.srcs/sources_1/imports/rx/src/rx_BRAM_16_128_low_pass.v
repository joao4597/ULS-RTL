// Simple Dual-Port Block RAM with One Clock
// File: simple_dual_one_clock.v

/**
 * GENERAL DESCRIPTION:
 *
 * -16 bit by 128 lines RAM that holds the 128 coefficients of a low pass filter
 * -FPass -> 45 KHz || FCut -> 100KHz
 *
 *
 * CONSTRAINTS:
 *
 *
 */

module rx_BRAM_16_128_low_pass (clk, rrx_rst, ena,enb,wea,addra,addrb,dia,dob);

  input                clk    ;  //clock
  input                rrx_rst;
  input                ena    ;  //enable
  input                enb    ;  //enable read
  input                wea    ;  //write enable
  input          [6:0] addra  ;  //write address
  input          [6:0] addrb  ;  //read addr
  input  signed [15:0] dia    ;  //data in
  output signed [15:0] dob    ;  //data out

  reg signed [15:0] ram [127:0];
  reg signed [15:0] doa        ;
  reg signed [15:0] dob        ;

  integer i;

  //set initial value of memories to zero
  initial begin
    ram[0] = 0;
    ram[1] = 0;
    ram[2] = 0;
    ram[3] = 0;
    ram[4] = 0;
    ram[5] = 0;
    ram[6] = 0;
    ram[7] = 0;
    ram[8] = 0;
    ram[9] = 0;
    ram[10] = 0;
    ram[11] = 0;
    ram[12] = 0;
    ram[13] = 0;
    ram[14] = 0;
    ram[15] = 0;
    ram[16] = 0;
    ram[17] = 0;
    ram[18] = 0;
    ram[19] = 0;
    ram[20] = 0;
    ram[21] = 0;
    ram[22] = 0;
    ram[23] = 0;
    ram[24] = 0;
    ram[25] = 0;
    ram[26] = 0;
    ram[27] = 0;
    ram[28] = -1;
    ram[29] = -1;
    ram[30] = -1;
    ram[31] = 0;
    ram[32] = 0;
    ram[33] = 1;
    ram[34] = 1;
    ram[35] = 2;
    ram[36] = 2;
    ram[37] = 2;
    ram[38] = 1;
    ram[39] = -1;
    ram[40] = -3;
    ram[41] = -5;
    ram[42] = -6;
    ram[43] = -5;
    ram[44] = -2;
    ram[45] = 2;
    ram[46] = 6;
    ram[47] = 10;
    ram[48] = 13;
    ram[49] = 12;
    ram[50] = 7;
    ram[51] = -1;
    ram[52] = -11;
    ram[53] = -21;
    ram[54] = -28;
    ram[55] = -29;
    ram[56] = -22;
    ram[57] = -5;
    ram[58] = 21;
    ram[59] = 54;
    ram[60] = 89;
    ram[61] = 122;
    ram[62] = 147;
    ram[63] = 161;
    ram[64] = 161;
    ram[65] = 147;
    ram[66] = 122;
    ram[67] = 89;
    ram[68] = 54;
    ram[69] = 21;
    ram[70] = -5;
    ram[71] = -22;
    ram[72] = -29;
    ram[73] = -28;
    ram[74] = -21;
    ram[75] = -11;
    ram[76] = -1;
    ram[77] = 7;
    ram[78] = 12;
    ram[79] = 13;
    ram[80] = 10;
    ram[81] = 6;
    ram[82] = 2;
    ram[83] = -2;
    ram[84] = -5;
    ram[85] = -6;
    ram[86] = -5;
    ram[87] = -3;
    ram[88] = -1;
    ram[89] = 1;
    ram[90] = 2;
    ram[91] = 2;
    ram[92] = 2;
    ram[93] = 1;
    ram[94] = 1;
    ram[95] = 0;
    ram[96] = 0;
    ram[97] = -1;
    ram[98] = -1;
    ram[99] = -1;
    ram[100] = 0;
    ram[101] = 0;
    ram[102] = 0;
    ram[103] = 0;
    ram[104] = 0;
    ram[105] = 0;
    ram[106] = 0;
    ram[107] = 0;
    ram[108] = 0;
    ram[109] = 0;
    ram[110] = 0;
    ram[111] = 0;
    ram[112] = 0;
    ram[113] = 0;
    ram[114] = 0;
    ram[115] = 0;
    ram[116] = 0;
    ram[117] = 0;
    ram[118] = 0;
    ram[119] = 0;
    ram[120] = 0;
    ram[121] = 0;
    ram[122] = 0;
    ram[123] = 0;
    ram[124] = 0;
    ram[125] = 0;
    ram[126] = 0;
    ram[127] = 0;
    //ram[127] = -1;
/*
    //USED ONLY FOR DEBBUGING PURPOSES
    for (i = 1; i < 128; i = i + 1) begin
      ram[i] = 0;
    end
    ram[127] = 1;
    //USED ONLY FOR DEBBUGING PURPOSES
*/

    dob = ram[127];
  end

  always @(posedge clk) begin
   if (ena) begin
      if (wea)
          ram[addra] <= dia;
   end
  end

  always @(posedge clk) begin
    if (rrx_rst) begin
      dob <= ram[127];
    end else begin
      if (enb) begin
        dob <= ram[addrb];
      end
    end
  end

endmodule
