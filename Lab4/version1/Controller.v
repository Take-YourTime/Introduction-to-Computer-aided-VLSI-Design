`timescale 1ns/1ps
`define bits 9
`define S0  4'b0000
`define S1  4'b0001
`define S2  4'b0010
`define S3  4'b0011
`define S4  4'b0100
`define S5  4'b0101
`define S6  4'b0110
`define S7  4'b0111
`define S8  4'b1000
`define S9  4'b1001
`define S10 4'b1010
`define S11 4'b1011

module Controller (start, rst_n, clk, done, control);
    input start, rst_n, clk;
    output reg done;
    output reg [21:0] control;

    reg [3:0] Current_State, Next_State;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            Current_State <= `S0;
        else
            Current_State <= Next_State;
    end

    always @(*) begin
        case(Current_State)
            `S0:  Next_State = (start) ? `S1 : `S0;
            `S1:  Next_State = `S2;
            `S2:  Next_State = `S3;
            `S3:  Next_State = `S4;
            `S4:  Next_State = `S5;
            `S5:  Next_State = `S6;
            `S6:  Next_State = `S7;
            `S7:  Next_State = `S8;
            `S8:  Next_State = `S9;
            `S9:  Next_State = `S10;
            `S10: Next_State = `S11;
            `S11: Next_State = `S0;
            default: Next_State = `S0;
        endcase
    end

    always @(*) begin
        done = 1'b0;
        control = 22'b0;

        case(Current_State)
            // control = {r1,r2,r3,r4,r5,r6,ROM,M1,M2,M3,M4,M5,M6,M7,M8,M9}
            // S0: load R, G, B into r1, r2, r3.
            `S0: begin
                control = 22'b1_1_1_0_0_0_000_00_00_00_0_00_0_0_0_0;
                done = 1'b0;
            end

            // t1 = R * 0.299 -> r4
            `S1: begin
                control = 22'b0_0_0_1_0_0_000_10_00_00_0_00_0_0_0_0;
                done = 1'b0;
            end

            // t2 = G * 0.587 -> r5
            `S2: begin
                control = 22'b0_0_0_0_1_0_001_01_00_00_0_00_0_0_0_0;
                done = 1'b0;
            end

            // TODO

            // t6 = R * (-0.169) -> r5, t4 = t1 + t2 -> r4
            `S3: begin
                control = 22'b0_0_0_1_1_0_010_10_10_11_0_00_0_1_0_0;
                done = 1'b0;
            end

            // t7 = G * (-0.331) -> r6
            `S4: begin
                control = 22'b0_0_0_0_0_1_011_01_00_00_0_00_0_0_0_0;
                done = 1'b0;
            end

            // t8 = B * 0.5 -> r5, t9 = t6 + t7 -> r6
            `S5: begin
                control = 22'b0_0_0_0_1_1_100_00_01_00_0_00_0_0_0_1;
                done = 1'b0;
            end

            // t12 = R * 0.5 -> r5, t10 = 128 + t8 -> r1
            `S6: begin
                control = 22'b1_0_0_0_1_0_100_10_00_11_1_00_0_0_0_0;
                done = 1'b0;
            end

            // t13 = G * (-0.419) -> r2, U = t10 + t9 -> r1
            `S7: begin
                control = 22'b1_1_0_0_0_0_101_01_11_00_1_01_0_0_0_0;
                done = 1'b0;
            end

            // t14 = B * (-0.081) -> r2, t15 = t12 + t13 -> r5
            `S8: begin
                control = 22'b0_1_0_0_1_0_110_00_01_10_0_01_0_0_1_0;
                done = 1'b0;
            end

            // t3 = B * 0.114 -> r2, t16 = 128 + t14 -> r3
            `S9: begin
                control = 22'b0_1_1_0_0_0_111_00_00_10_0_01_1_0_0_0;
                done = 1'b0;
            end

            // Y = t4 + t3 -> r2
            `S10: begin
                control = 22'b0_1_0_0_0_0_000_00_10_10_0_10_0_0_0_0;
                done = 1'b0;
            end

            // V = t15 + t16 -> r3, final output next clock via done
            `S11: begin
                control = 22'b0_0_1_0_0_0_000_00_01_01_0_00_1_0_0_0;
                done = 1'b1;
            end

            default: begin
                control = 22'b0_0_0_0_0_0_000_00_00_00_0_00_0_0_0_0;
                done = 1'b0;
            end
        endcase
    end
endmodule
