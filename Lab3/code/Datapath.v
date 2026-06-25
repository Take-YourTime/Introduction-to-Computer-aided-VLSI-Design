`timescale 1ns/1ps
`define bits 9

module Datapath (
    inportR, inportG, inportB,
    control,
    clk, rst_n,
    outportY, outportU, outportV,
    done
);
    input [`bits-1:0] inportR, inportG, inportB; // RGB
    input [21:0] control;
    input clk, rst_n, done;
    output [`bits-1:0] outportY, outportU, outportV;

    wire [`bits-1:0] M1_OUT, M2_OUT, M3_OUT;
    wire [`bits-1:0] M4_OUT, M5_OUT, M6_OUT, M7_OUT, M8_OUT, M9_OUT;
    wire [`bits-1:0] Fadd, Fmul, data;
    wire [`bits-1:0] R1, R2, R3, R4, R5, R6;

    // control = {r1,r2,r3,r4,r5,r6,    ROM[2:0],   M1[1:0],    M2[1:0],    M3[1:0],M4,M5[1:0],M6,M7,M8,M9}
    //            21 20 19 18 17 16     15 14 13    12 11      `10 9       `8 7     6  5 4     3  2  1  0
    
    Register r1(.D(M4_OUT), .reset(rst_n), .clk(clk), .load(control[21]), .Q(R1));
    /*
    equal to:
        if(reset)
            R1 <= 0
        else if(control[21])
            R1 <= M4_OUT
    */
    Register r2(.D(M5_OUT), .reset(rst_n), .clk(clk), .load(control[20]), .Q(R2));
    Register r3(.D(M6_OUT), .reset(rst_n), .clk(clk), .load(control[19]), .Q(R3));
    Register r4(.D(M7_OUT), .reset(rst_n), .clk(clk), .load(control[18]), .Q(R4));
    Register r5(.D(M8_OUT), .reset(rst_n), .clk(clk), .load(control[17]), .Q(R5));

    Register r6(.D(M9_OUT), .reset(rst_n), .clk(clk), .load(control[16]), .Q(R6));

    // Functional unit input selection.
    MUX3 M1(.A(R3), .B(R2), .C(R1), .S(control[12:11]), .Y(M1_OUT));
    MUX4 M2(.A(9'b010000000), .B(R5), .C(R4), .D(R1), .S(control[10:9]), .Y(M2_OUT));
    MUX4 M3(.A(R6), .B(R3), .C(R2), .D(R5), .S(control[8:7]), .Y(M3_OUT));

    // Register input selection.
    MUX2 M4(.A(inportR), .B(Fadd), .S(control[6]), .Y(M4_OUT));
    MUX3 M5(.A(inportG), .B(Fmul), .C(Fadd), .S(control[5:4]), .Y(M5_OUT));
    MUX2 M6(.A(inportB), .B(Fadd), .S(control[3]), .Y(M6_OUT));
    MUX2 M7(.A(Fmul),  .B(Fadd), .S(control[2]), .Y(M7_OUT));
    MUX2 M8(.A(Fmul),  .B(Fadd), .S(control[1]), .Y(M8_OUT));
    MUX2 M9(.A(Fmul),  .B(Fadd), .S(control[0]), .Y(M9_OUT));

    Mul FU1(.A(M1_OUT), .B(data),   .Mul(Fmul));
    Add FU2(.A(M2_OUT), .B(M3_OUT), .Add(Fadd));
    ROM FU3(.clk(clk), .addr(control[15:13]), .data(data));

    // Output registers latch final Y/U/V when done = 1.
    Register r7(.D(R2), .reset(rst_n), .clk(clk), .load(done), .Q(outportY));
    Register r8(.D(R1), .reset(rst_n), .clk(clk), .load(done), .Q(outportU));
    Register r9(.D(Fadd), .reset(rst_n), .clk(clk), .load(done), .Q(outportV));
endmodule
