// Module: 4-bit Up Counter
// Description: A simple 4-bit counter with asynchronous active-low reset.

module counter (
    input  wire       clk,
    input  wire       rst_n, // Active Low Reset
    output reg  [3:0] out
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out <= 4'b0000;
        end else begin
            out <= out + 1;
        end
    end

endmodule
