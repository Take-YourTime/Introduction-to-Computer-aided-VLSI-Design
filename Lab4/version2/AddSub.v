`define bits 9

// One 9-bit adder/subtractor resource.
// sub = 0: Result = A + B
// sub = 1: Result = A - B
module AddSub (
    input  signed [`bits-1:0] A,
    input  signed [`bits-1:0] B,
    input                    sub,
    output signed [`bits-1:0] Result
);
    assign Result = sub ? (A - B) : (A + B);
endmodule
