`timescale 1ns/1ps
`define bits 9

// Top module for Lab 4 Version 2.
module RGB2YUV_V2 (
    input              start,
    input              clk,
    input              rst_n,
    input  [`bits-1:0] inportR,
    input  [`bits-1:0] inportG,
    input  [`bits-1:0] inportB,
    output             done,
    output [`bits-1:0] outportY,
    output [`bits-1:0] outportU,
    output [`bits-1:0] outportV
);
    wire [2:0] step;

    Controller_V2 Controller(
        .start(start),
        .rst_n(rst_n),
        .clk(clk),
        .done(done),
        .step(step)
    );

    Datapath_V2 Datapath(
        .inportR(inportR),
        .inportG(inportG),
        .inportB(inportB),
        .step(step),
        .clk(clk),
        .rst_n(rst_n),
        .outportY(outportY),
        .outportU(outportU),
        .outportV(outportV)
    );
endmodule
