///////////////////////////////////////////////////////////////////////
// Purpose : 104_2 lowpower course provided by VLSIDA lab.
///////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
`define bits 8
`define S0 3'b000
`define S1 3'b001
`define S2 3'b010
`define S3 3'b011
`define S4 3'b100
`define S5 3'b101
`define S6 3'b110
`define S7 3'b111

module GCD (
  input  start, clk, rst_n,
  input  [`bits-1:0] inport,
  output done,
  output [`bits-1:0] outport
  );

wire load_A, load_B, load_R, M2_sel, M3_sel;
wire [1:0] M1_sel;
wire C_1, C_2;

Controller Controller (
  .start(start),
  .C_1(C_1),
  .C_2(C_2),
  .rst_n(rst_n),
  .clk(clk),
  .load_A(load_A),
  .load_B(load_B),
  .load_R(load_R),
  .M1_sel (M1_sel),
  .M2_sel (M2_sel),
  .M3_sel (M3_sel),
  .done(done)
);

Datapath Datapath (
  .inport(inport),
  .load_A(load_A),
  .load_B(load_B),
  .load_R(load_R),
  .M1_sel (M1_sel),
  .M2_sel (M2_sel),
  .M3_sel (M3_sel),
  .clk(clk),
  .rst_n(rst_n),
  .outport(outport),
  .C_1(C_1),
  .C_2(C_2)
);

endmodule

module Controller (
  input start, C_1, C_2 , rst_n, clk,
  output reg load_A, load_B, load_R, M2_sel, M3_sel, done,
  output reg [1:0] M1_sel
  );

reg [2:0] Current_State, Next_State;

// State Register
always @(posedge clk or negedge rst_n) begin
  if(!rst_n)
    Current_State <= `S0;
  else
    Current_State <= Next_State;
end

// Next_State Logic
always @(*) begin
  case (Current_State)
  `S0: begin
    if(!start)
      Next_State = `S0;
    else
      Next_State = `S1;
  end
 
  `S1: begin
    Next_State = `S2;
  end
 
  `S2: begin
    Next_State = `S3;
  end
 
  `S3: begin
    if(!C_1)
      Next_State = `S5;
    else
      Next_State = `S4;
  end
 
  `S4: begin
    Next_State = `S3;
  end
 
  `S5: begin
    if(!C_2)
      Next_State = `S7;
    else
      Next_State = `S6;
  end
 
  `S6: begin
    Next_State = `S3;
  end
 
  `S7: begin
    Next_State = `S0;
  end

  endcase
end

// Output Logic
always @(*) begin
  case (Current_State)
  `S0: begin
    load_A = 1'b0;
    load_B = 1'b0;
    load_R = 1'b0;
    M1_sel = 2'b00;
    M2_sel = 1'b0;
    M3_sel = 1'b0;
    done = 1'b0;
  end
 
  `S1: begin
    load_A = 1'b1;
    load_B = 1'b0;
    load_R = 1'b0;
    M1_sel = 2'b01;
    M2_sel = 1'b0;
    M3_sel = 1'b0;
    done = 1'b0;
  end
 
  `S2: begin
    load_A = 1'b0;
    load_B = 1'b1;
    load_R = 1'b0;
    M1_sel = 2'b00;
    M2_sel = 1'b0;
    M3_sel = 1'b0;
    done = 1'b0;
  end
 
  `S3: begin
    load_A = 1'b0;
    load_B = 1'b0;
    load_R = 1'b0;
    M1_sel = 2'b00;
    M2_sel = 1'b0;
    M3_sel = 1'b0;
    done = 1'b0;
  end
 
  `S4: begin
    load_A = 1'b1;
    load_B = 1'b0;
    load_R = 1'b0;
    M1_sel = 2'b00;
    M2_sel = 1'b0;
    M3_sel = 1'b0;
    done = 1'b0;
  end
 
  `S5: begin
    load_A = 1'b0;
    load_B = 1'b0;
    load_R = 1'b1;
    M1_sel = 2'b00;
    M2_sel = 1'b0;
    M3_sel = 1'b1;
    done = 1'b0;
  end
 
  `S6: begin
    load_A = 1'b1;
    load_B = 1'b1;
    load_R = 1'b0;
    M1_sel = 2'b10;
    M2_sel = 1'b1;
    M3_sel = 1'b0;
    done = 1'b0;
  end
 
  `S7: begin
    load_A = 1'b0;
    load_B = 1'b0;
    load_R = 1'b0;
    M1_sel = 2'b00;
    M2_sel = 1'b0;
    M3_sel = 1'b0;
    done = 1'b1;
  end

  endcase
end

endmodule

module Datapath (
  input  [`bits-1:0] inport,
  input load_A, load_B, load_R, M2_sel, M3_sel,
  input [1:0] M1_sel,
  input  clk, rst_n,
  output [`bits-1:0] outport,
  output C_1, C_2
  );

wire [`bits-1:0] M1_OUT, M2_OUT, M3_OUT, Fsub, A_reg, B_reg, R_reg;

Register A (
  .D(M1_OUT),
  .reset(rst_n),
  .clk(clk),
  .load(load_A),
  .Q(A_reg)
);

Register B (
  .D(M2_OUT),
  .reset(rst_n),
  .clk(clk),
  .load(load_B),
  .Q(B_reg)
);

Register R (
  .D(A_reg),
  .reset(rst_n),
  .clk(clk),
  .load(load_R),
  .Q(R_reg)
);

MUX3 M1 (
  .A(Fsub),
  .B(inport),
  .C(B_reg),
  .S(M1_sel),
  .Y(M1_OUT)
);

MUX2 M2 (
  .A(inport),
  .B(R_reg),
  .S(M2_sel),
  .Y(M2_OUT)
);

MUX2 M3 (
  .A(B_reg),
  .B(8'd0),
  .S(M3_sel),
  .Y(M3_OUT)
);

Sub FU1 (
  .A(A_reg),
  .B(B_reg),
  .Sub(Fsub)
);

Compare FU2(
  .A(A_reg),
  .B(M3_OUT),
  .C_1(C_1),
  .C_2(C_2)
);

assign outport = B_reg;

endmodule

module Register (
  input  [`bits-1:0] D,
  input  reset, clk, load,
  output reg [`bits-1:0] Q
  );

  always @(posedge clk or negedge reset) begin
  if(!reset)
    Q <= 8'b0;
  else if(load)
    Q <= D;
  end

endmodule

module MUX2 (
  input [`bits-1:0] A, B,
  input  S,
  output reg [`bits-1:0] Y
  );

  always @(*) begin
  case (S)
    1'b0: Y = A;
    1'b1: Y = B;
  endcase
  end

endmodule

module MUX3 (
  input  [`bits-1:0] A, B, C,
  input  [1:0] S,
  output reg [`bits-1:0] Y
  );

  always @(*) begin
  case (S)
    2'b00: Y = A;
    2'b01: Y = B;
    2'b10: Y = C;
    default : Y = A;
  endcase
  end

endmodule

module Sub (
  input  [`bits-1:0] A, B,
  output [`bits-1:0] Sub
  );

  assign Sub = A - B;

endmodule

module Compare (
  input [`bits-1:0] A, B,
  output reg C_1, C_2
  );

  always @(*) begin
  if( A >= B )
    C_1 = 1'b1;
  else
    C_1 = 1'b0;
 
  if( A == B )
   C_2 = 1'b0;
  else
   C_2 = 1'b1;
  end

endmodule
