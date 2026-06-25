`define bits 9

// Signed Q1.8 fixed-point multiplier.
// The coefficient is scaled by 2^8 = 256.
// After multiplication, bits [16:8] are retained to scale the result back.
module Mul (A, B, Mul);
    input  signed [`bits-1:0] A;
    input  signed [`bits-1:0] B;
    output signed [`bits-1:0] Mul;

    wire signed [2*`bits-1:0] product;

    assign product = A * B;
    assign Mul     = product[16:8];
endmodule
