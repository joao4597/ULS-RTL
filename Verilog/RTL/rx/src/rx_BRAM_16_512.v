// Simple Dual-Port Block RAM with One Clock
// File: simple_dual_one_clock.v

/**
 * GENERAL DESCRIPTION:
 *
 * -Multipurpose 16 bit by 512 lines RAM
 *
 *
 * CONSTRAINTS:
 *
 *
 */

module rx_BRAM_16_512 (clk, rrx_rst, ena,enb,wea,addra,addrb,dia,dob);

  input                clk    ;  //clock
  input                rrx_rst;
  input                ena    ;  //enable
  input                enb    ;  //enable read
  input                wea    ;  //write enable
  input          [8:0] addra  ;  //write address
  input          [8:0] addrb  ;  //read addr
  input  signed [15:0] dia    ;  //data in
  output signed [15:0] dob    ;  //data out

  reg signed [15:0] ram [511:0];
  reg signed [15:0] doa         ;
  reg signed [15:0] dob         ;

  integer i;

  //set initial value of memories to zero
  initial begin
    for (i = 0; i < 1024; i = i + 1) begin
      ram[i] = 0;
    end
  end

  always @(posedge clk) begin
   if (ena) begin
      if (wea)
          ram[addra] <= dia;
   end
  end

  always @(posedge clk) begin
    if (rrx_rst) begin
      dob <= 0;
    end else begin
      if (enb) begin
        dob <= ram[addrb];
      end
    end
  end

endmodule
