`timescale 1ns/1ps

module pipelined_relu (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [15:0] data_in,
    output logic [15:0] data_out
);

    logic [15:0] data_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_reg <= '0;
        end else begin
            if (data_in[15]) begin
                data_reg <= 16'b0;
            end else begin
                data_reg <= data_in;
            end
        end
    end

    assign data_out = data_reg;

endmodule