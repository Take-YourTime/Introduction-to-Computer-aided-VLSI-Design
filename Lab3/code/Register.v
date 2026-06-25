`define bits 9
module Register (
    input  [`bits-1:0] D,
    input  reset, clk, load,
    output reg [`bits-1:0] Q
);
    always @(posedge clk or negedge reset) begin
        if(!reset)
            Q <= 9'b0;
        else if(load)
            Q <= D;
    end
endmodule