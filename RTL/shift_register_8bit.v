module shift_register_8bit (
    input wire clk,
    input wire rst_n,
    input wire shift_en,
    input wire serial_in,
    output reg [7:0] parallel_out,
    output wire serial_out
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            parallel_out <= 8'b0;
        end else if (shift_en) begin
            parallel_out <= {parallel_out[6:0], serial_in};
        end
    end
    
    assign serial_out = parallel_out[7];

endmodule