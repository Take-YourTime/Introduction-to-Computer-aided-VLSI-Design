///////////////////////////////////////////////////////////////////////
// Purpose : 107_1 ESL course provided by VLSIDA lab.
///////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns
`define bits 8

module testbench;

parameter half_clk = 10;
parameter clk_period = 2 * half_clk;

reg   clk, rst_n, start;
reg   [`bits-1:0] inport, a;
wire  done;
wire  [`bits-1:0] outport;

integer i;

GCD GCD( .start(start), .inport(inport), .clk(clk), .rst_n(rst_n), .outport(outport), .done(done));

initial
begin
  $dumpvars();
  $dumpfile("./GCD_syn.vcd");
  $sdf_annotate("./GCD_syn.sdf",GCD);
end

initial begin
  clk = 1'b0;
  rst_n = 1'b1;
  #(clk_period) rst_n = ~rst_n;
  #(clk_period) rst_n = ~rst_n;
end

always
  #(half_clk) clk = ~clk;

initial begin
  start = 1'b0;
  a = 8'd0;
  inport = 8'd0;


  #(clk_period*2)
  start = ~start;
  inport = 8'd18;
  a=inport;

  #(clk_period*2)
  inport = 8'd9;

  #(clk_period)
  start = ~start;

  wait(done);
  $display("i = %d, time = %t, A = %d, B = %d, Outport = %d",i,$time,a,inport, outport);

  $finish;
end

endmodule

