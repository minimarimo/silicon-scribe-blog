`timescale 1ns/1ps

// DMA Controller with Burst Transfers
module dma_controller #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter BURST_LEN  = 4
) (
    input  logic                 clk,
    input  logic                 rst_n,
    input  logic                 start,
    input  logic [ADDR_WIDTH-1:0] src_addr,
    input  logic [ADDR_WIDTH-1:0] dst_addr,
    input  logic [BURST_LEN-1:0]  burst_len,
    output logic                 done,
    output logic [ADDR_WIDTH-1:0] curr_src_addr,
    output logic [ADDR_WIDTH-1:0] curr_dst_addr,
    output logic [BURST_LEN-1:0]  curr_burst_len,
    output logic                 read_en,
    output logic                 write_en
);

    logic [BURST_LEN-1:0] burst_cnt;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            curr_src_addr <= '0;
            curr_dst_addr <= '0;
            curr_burst_len <= '0;
            read_en <= 1'b0;
            write_en <= 1'b0;
            done <= 1'b0;
            burst_cnt <= '0;
        end else if (start) begin
            curr_src_addr <= src_addr;
            curr_dst_addr <= dst_addr;
            curr_burst_len <= burst_len;
            read_en <= 1'b1;
            write_en <= 1'b1;
            done <= 1'b0;
            burst_cnt <= '0;
        end else if (burst_cnt < burst_len) begin
            curr_src_addr <= curr_src_addr + DATA_WIDTH/8;
            curr_dst_addr <= curr_dst_addr + DATA_WIDTH/8;
            curr_burst_len <= curr_burst_len - 1'b1;
            burst_cnt <= burst_cnt + 1'b1;
        end else begin
            read_en <= 1'b0;
            write_en <= 1'b0;
            done <= 1'b1;
        end
    end

endmodule