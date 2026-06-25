`timescale 1ns/1ps

// Version 2 controller:
// S0      : load one RGB pixel
// S1 ~ S5 : execute the five scheduled control steps
// done is asserted in S5. The output registers are updated when S5 ends.
module Controller_V2 (
    input            start,
    input            rst_n,
    input            clk,
    output reg       done,
    output reg [2:0] step
);
    localparam S0 = 3'd0;
    localparam S1 = 3'd1;
    localparam S2 = 3'd2;
    localparam S3 = 3'd3;
    localparam S4 = 3'd4;
    localparam S5 = 3'd5;

    reg [2:0] Current_State;
    reg [2:0] Next_State;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            Current_State <= S0;
        else
            Current_State <= Next_State;
    end

    always @(*) begin
        case (Current_State)
            S0: Next_State = start ? S1 : S0;
            S1: Next_State = S2;
            S2: Next_State = S3;
            S3: Next_State = S4;
            S4: Next_State = S5;
            S5: Next_State = S0;
            default: Next_State = S0;
        endcase
    end

    always @(*) begin
        step = Current_State;
        done = (Current_State == S5);
    end
endmodule
