module lfsr_8bit (
    input clk,
    input rst,
    output reg [7:0] q
);

    reg [7:0] lfsr;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            lfsr <= 8'b10000000;
        end else begin
            lfsr[7:1] <= lfsr[6:0];
            lfsr[0] <= lfsr[7] ^ lfsr[5];
            q <= lfsr;
        end
    end

endmodule