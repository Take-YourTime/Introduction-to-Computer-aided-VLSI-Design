`define bits 9

module Add(A, B, Add);
    input  signed [`bits-1:0] A, B;
    output signed [`bits-1:0] Add;

    assign Add = A + B;
endmodule
