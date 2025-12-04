`timescale 1ns/1ps

// Design Module
module pipelined_relu #(
    parameter DATA_WIDTH = 16
) (
    input  logic                 clk,
    input  logic                 rst_n,
    input  logic [DATA_WIDTH-1:0] din,
    output logic [DATA_WIDTH-1:0] dout
);

    logic [DATA_WIDTH-1:0] stage1, stage2;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            stage1 <= '0;
            stage2 <= '0;
        end
        else begin
            stage1 <= (din[DATA_WIDTH-1]) ? '0 : din;
            stage2 <= stage1;
        end
    end

    assign dout = stage2;

endmodule