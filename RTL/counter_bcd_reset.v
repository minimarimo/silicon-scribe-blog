//////////////////////////////////////////////////////////////////////////////
// Module: bcd_counter
// Description: 4-bit BCD counter that counts from 0 to 9 with synchronous reset
//////////////////////////////////////////////////////////////////////////////

module bcd_counter (
    input  wire       clk,      // Clock input
    input  wire       rst,      // Synchronous reset (active high)
    input  wire       enable,   // Counter enable
    output reg  [3:0] count,    // 4-bit BCD count output (0-9)
    output wire       carry     // Carry output (high when count wraps from 9 to 0)
);

    // Carry is asserted when counter is at 9 and enabled
    assign carry = (count == 4'd9) && enable;

    // Synchronous counter logic
    always @(posedge clk) begin
        if (rst) begin
            count <= 4'd0;
        end
        else if (enable) begin
            if (count >= 4'd9) begin
                count <= 4'd0;  // Wrap around after 9
            end
            else begin
                count <= count + 4'd1;
            end
        end
        // If not enabled, count holds its value
    end

endmodule