// 8-bit Ring Counter Module
// A ring counter circulates a single '1' bit through the register
// Pattern: 00000001 -> 00000010 -> 00000100 -> ... -> 10000000 -> 00000001

module ring_counter_8bit (
    input  wire       clk,      // Clock input
    input  wire       rst_n,    // Active-low asynchronous reset
    input  wire       enable,   // Enable signal
    output reg  [7:0] q         // 8-bit output
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset: Initialize with single '1' at LSB
            q <= 8'b00000001;
        end
        else if (enable) begin
            // Rotate left: shift left and wrap MSB to LSB
            q <= {q[6:0], q[7]};
        end
    end

endmodule