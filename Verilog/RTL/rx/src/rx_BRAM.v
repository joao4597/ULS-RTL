// Simple Dual-Port Block RAM with One Clock
// File: simple_dual_one_clock.v

module rx_BRAM (clk,ena,enb,wea,addra,addrb,dia,dob);
  
  input         clk  ;  //clock
  input         ena  ;  //enable
  input         enb  ;  //enable read
  input         wea  ;  //write enable
  input  [8:0]  addra;  //write address
  input  [8:0]  addrb;  //read addr
  input  [17:0] dia  ;  //data in
  output [17:0] dob  ;  //data out
  
  reg [17:0] ram [1023:0];
  reg [17:0] doa         ;
  reg [17:0] dob         ;
  
  integer i;

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
    if (enb)
      dob <= ram[addrb];
  end
  
endmodule