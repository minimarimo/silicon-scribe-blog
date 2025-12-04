// 5-bit Johnson Counter
// A Johnson counter shifts data through a ring of flip-flops
// with the inverted output of the last flip-flop fed back to the first

module johnson_counter_5bit (
    input  wire       clk,
    input  wire       rst_n,    // Active-low asynchronous reset
    input  wire       enable,   // Enable signal
    output reg  [4:0] q         // 5-bit counter output
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q <= 5'b00000;
        end
        else if (enable) begin
            // Shift left and feed inverted MSB to LSB
            q <= {q[3:0], ~q[4]};
        end
    end

endmodule