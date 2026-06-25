`define bits 9

module MUX3 (
    input  [`bits-1:0] A, B, C,
    input  [1:0] S,
    output reg [`bits-1:0] Y
);
    always @(*) begin
        case (S)
            2'b00: Y = A;
            2'b01: Y = B;
            2'b10: Y = C;
        default : Y = A;
        endcase
    end
endmodule