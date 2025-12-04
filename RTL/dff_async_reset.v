//-----------------------------------------------------------------------------
// Module: d_ff_async_reset
// Description: D Flip-Flop with Asynchronous Active-High Reset
//-----------------------------------------------------------------------------
module d_ff_async_reset (
    input  wire clk,      // Clock input
    input  wire rst,      // Asynchronous reset (active high)
    input  wire d,        // Data input
    output reg  q         // Data output
);

    // D Flip-Flop with asynchronous reset
    // Reset has priority and is level-sensitive
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            q <= 1'b0;    // Asynchronous reset - clear output
        end else begin
            q <= d;       // On clock edge, capture input data
        end
    end

endmodule