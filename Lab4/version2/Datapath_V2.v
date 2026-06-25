`timescale 1ns/1ps
`define bits 9

// RGB-to-YUV datapath using exactly:
//   - 3 multipliers
//   - 3 adders/subtractors
// The five scheduled control steps are selected by step[2:0].
module Datapath_V2 (
    input  [`bits-1:0] inportR,
    input  [`bits-1:0] inportG,
    input  [`bits-1:0] inportB,
    input  [2:0]       step,
    input              clk,
    input              rst_n,
    output [`bits-1:0] outportY,
    output [`bits-1:0] outportU,
    output [`bits-1:0] outportV
);
    // ------------------------------------------------------------------
    // Fixed-point constants: unsigned magnitudes scaled by 256.
    // Subtraction is performed explicitly by the AddSub resources.
    // ------------------------------------------------------------------
    localparam [`bits-1:0] C_0299 = 9'b001001100; //  76 / 256 ~= 0.299
    localparam [`bits-1:0] C_0587 = 9'b010010110; // 150 / 256 ~= 0.587
    localparam [`bits-1:0] C_0169 = 9'b000101011; //  43 / 256 ~= 0.169
    localparam [`bits-1:0] C_0331 = 9'b001010100; //  84 / 256 ~= 0.331
    localparam [`bits-1:0] C_0500 = 9'b010000000; // 128 / 256  = 0.5
    localparam [`bits-1:0] C_0419 = 9'b001101011; // 107 / 256 ~= 0.419
    localparam [`bits-1:0] C_0081 = 9'b000010101; //  21 / 256 ~= 0.081
    localparam [`bits-1:0] C_0114 = 9'b000011101; //  29 / 256 ~= 0.114
    localparam [`bits-1:0] CONST_128 = 9'b010000000;
    localparam [`bits-1:0] CONST_0   = 9'b000000000;

    // Input registers.
    wire [`bits-1:0] R;
    wire [`bits-1:0] G;
    wire [`bits-1:0] B;

    // Intermediate registers, named after the DFG nodes.
    wire [`bits-1:0] t1, t2, t3, t4;
    wire [`bits-1:0] t6, t7, t8, t9, t10;
    wire [`bits-1:0] t12, t13, t14, t15, t16;

    // Functional-unit inputs and outputs.
    reg  signed [`bits-1:0] mul1_A, mul1_B;
    reg  signed [`bits-1:0] mul2_A, mul2_B;
    reg  signed [`bits-1:0] mul3_A, mul3_B;
    wire signed [`bits-1:0] mul1_out, mul2_out, mul3_out;

    reg  signed [`bits-1:0] alu1_A, alu1_B;
    reg  signed [`bits-1:0] alu2_A, alu2_B;
    reg  signed [`bits-1:0] alu3_A, alu3_B;
    reg                     alu1_sub, alu2_sub, alu3_sub;
    wire signed [`bits-1:0] alu1_out, alu2_out, alu3_out;

    // Register load enables.
    wire load_rgb  = (step == 3'd0);
    wire load_s1   = (step == 3'd1);
    wire load_s2   = (step == 3'd2);
    wire load_s3   = (step == 3'd3);
    wire load_s4   = (step == 3'd4);
    wire load_s5   = (step == 3'd5);

    // ------------------------------------------------------------------
    // Three multiplier resources.
    // ------------------------------------------------------------------
    Mul MUL1(.A(mul1_A), .B(mul1_B), .Mul(mul1_out));
    Mul MUL2(.A(mul2_A), .B(mul2_B), .Mul(mul2_out));
    Mul MUL3(.A(mul3_A), .B(mul3_B), .Mul(mul3_out));

    // ------------------------------------------------------------------
    // Three adder/subtractor resources.
    // ------------------------------------------------------------------
    AddSub ALU1(.A(alu1_A), .B(alu1_B), .sub(alu1_sub), .Result(alu1_out));
    AddSub ALU2(.A(alu2_A), .B(alu2_B), .sub(alu2_sub), .Result(alu2_out));
    AddSub ALU3(.A(alu3_A), .B(alu3_B), .sub(alu3_sub), .Result(alu3_out));

    // ------------------------------------------------------------------
    // Combinational routing. This case statement synthesizes into MUXes.
    // ------------------------------------------------------------------
    always @(*) begin
        // Default values for unused resources.
        mul1_A = CONST_0; mul1_B = CONST_0;
        mul2_A = CONST_0; mul2_B = CONST_0;
        mul3_A = CONST_0; mul3_B = CONST_0;

        alu1_A = CONST_0; alu1_B = CONST_0; alu1_sub = 1'b0;
        alu2_A = CONST_0; alu2_B = CONST_0; alu2_sub = 1'b0;
        alu3_A = CONST_0; alu3_B = CONST_0; alu3_sub = 1'b0;

        case (step)
            // Pick 1: t1, t2, t6
            3'd1: begin
                mul1_A = R; mul1_B = C_0299; // t1  = R * 0.299
                mul2_A = G; mul2_B = C_0587; // t2  = G * 0.587
                mul3_A = R; mul3_B = C_0169; // t6  = R * 0.169
            end

            // Pick 2: t7, t8, t12, t4
            3'd2: begin
                mul1_A = G; mul1_B = C_0331; // t7  = G * 0.331
                mul2_A = B; mul2_B = C_0500; // t8  = B * 0.5
                mul3_A = R; mul3_B = C_0500; // t12 = R * 0.5

                alu1_A = t1; alu1_B = t2; alu1_sub = 1'b0; // t4 = t1 + t2
            end

            // Pick 3: t13, t14, t3, t9, t10
            3'd3: begin
                mul1_A = G; mul1_B = C_0419; // t13 = G * 0.419
                mul2_A = B; mul2_B = C_0081; // t14 = B * 0.081
                mul3_A = B; mul3_B = C_0114; // t3  = B * 0.114

                alu1_A = t6;       alu1_B = t7; alu1_sub = 1'b0; // t9  = t6 + t7
                alu2_A = CONST_128; alu2_B = t8; alu2_sub = 1'b0; // t10 = 128 + t8
            end

            // Pick 4: t15, t16, Y
            3'd4: begin
                alu1_A = t12;      alu1_B = t13; alu1_sub = 1'b1; // t15 = t12 - t13
                alu2_A = CONST_128; alu2_B = t14; alu2_sub = 1'b1; // t16 = 128 - t14
                alu3_A = t4;       alu3_B = t3;  alu3_sub = 1'b0; // Y   = t4 + t3
            end

            // Pick 5: U, V
            // Important correction:
            // U = (128 + 0.5B) - (0.169R + 0.331G) = t10 - t9.
            3'd5: begin
                alu1_A = t10; alu1_B = t9;  alu1_sub = 1'b1; // U = t10 - t9
                alu2_A = t15; alu2_B = t16; alu2_sub = 1'b0; // V = t15 + t16
            end

            default: begin
                // Keep the default zero values.
            end
        endcase
    end

    // ------------------------------------------------------------------
    // Input registers: loaded in S0 before the five picks start.
    // ------------------------------------------------------------------
    Register r_R(.D(inportR), .reset(rst_n), .clk(clk), .load(load_rgb), .Q(R));
    Register r_G(.D(inportG), .reset(rst_n), .clk(clk), .load(load_rgb), .Q(G));
    Register r_B(.D(inportB), .reset(rst_n), .clk(clk), .load(load_rgb), .Q(B));

    // ------------------------------------------------------------------
    // Intermediate registers: written according to the fixed schedule.
    // ------------------------------------------------------------------
    Register r_t1 (.D(mul1_out), .reset(rst_n), .clk(clk), .load(load_s1), .Q(t1));
    Register r_t2 (.D(mul2_out), .reset(rst_n), .clk(clk), .load(load_s1), .Q(t2));
    Register r_t6 (.D(mul3_out), .reset(rst_n), .clk(clk), .load(load_s1), .Q(t6));

    Register r_t7 (.D(mul1_out), .reset(rst_n), .clk(clk), .load(load_s2), .Q(t7));
    Register r_t8 (.D(mul2_out), .reset(rst_n), .clk(clk), .load(load_s2), .Q(t8));
    Register r_t12(.D(mul3_out), .reset(rst_n), .clk(clk), .load(load_s2), .Q(t12));
    Register r_t4 (.D(alu1_out), .reset(rst_n), .clk(clk), .load(load_s2), .Q(t4));

    Register r_t13(.D(mul1_out), .reset(rst_n), .clk(clk), .load(load_s3), .Q(t13));
    Register r_t14(.D(mul2_out), .reset(rst_n), .clk(clk), .load(load_s3), .Q(t14));
    Register r_t3 (.D(mul3_out), .reset(rst_n), .clk(clk), .load(load_s3), .Q(t3));
    Register r_t9 (.D(alu1_out), .reset(rst_n), .clk(clk), .load(load_s3), .Q(t9));
    Register r_t10(.D(alu2_out), .reset(rst_n), .clk(clk), .load(load_s3), .Q(t10));

    Register r_t15(.D(alu1_out), .reset(rst_n), .clk(clk), .load(load_s4), .Q(t15));
    Register r_t16(.D(alu2_out), .reset(rst_n), .clk(clk), .load(load_s4), .Q(t16));
    Register r_Y  (.D(alu3_out), .reset(rst_n), .clk(clk), .load(load_s4), .Q(outportY));

    Register r_U  (.D(alu1_out), .reset(rst_n), .clk(clk), .load(load_s5), .Q(outportU));
    Register r_V  (.D(alu2_out), .reset(rst_n), .clk(clk), .load(load_s5), .Q(outportV));
endmodule
