`define bits 9

module MUX2 (
    input  [`bits-1:0] A, B,
    input  S,
    output reg [`bits-1:0] Y
);
    always @(*) begin
        case (S)
            1'b0: Y = A;
            1'b1: Y = B;
            default: Y = A;
        endcase
    end
endmodule
