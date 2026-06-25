`define bits 9

module Mul(A, B, Mul);
    input signed [`bits-1:0] A, B; 
    output [`bits-1:0] Mul;
    wire s;
    wire [7:0] N;

    assign {s, Mul, N} = A * B;
    
endmodule