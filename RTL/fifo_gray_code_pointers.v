`timescale 1ns/1ps

module fifo_gray #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 16
) (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        push,
    input  logic        pop,
    input  logic [DATA_WIDTH-1:0] data_in,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic        full,
    output logic        empty
);

    // Internal registers
    logic [DEPTH-1:0][DATA_WIDTH-1:0] mem;
    logic [$clog2(DEPTH)-1:0] write_ptr, read_ptr;
    logic [$clog2(DEPTH):0] fill_level;

    // Gray code pointer logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            write_ptr <= '0;
            read_ptr  <= '0;
        end
        else begin
            if (push && !full) write_ptr <= (write_ptr >> 1) ^ write_ptr;
            if (pop  && !empty) read_ptr <= (read_ptr >> 1) ^ read_ptr;
        end
    end

    // FIFO logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem       <= '0;
            fill_level <= '0;
        end
        else begin
            if (push && !full) begin
                mem[write_ptr] <= data_in;
                fill_level <= fill_level + 1;
            end
            if (pop && !empty) begin
                data_out <= mem[read_ptr];
                fill_level <= fill_level - 1;
            end
        end
    end

    // Flags
    assign full  = (fill_level == DEPTH);
    assign empty = (fill_level == '0);

endmodule