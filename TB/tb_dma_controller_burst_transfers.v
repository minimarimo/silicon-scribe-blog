`timescale 1ns/1ps

module dma_controller_tb;
    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 32;
    parameter BURST_LEN  = 4;

    logic                 clk;
    logic                 rst_n;
    logic                 start;
    logic [ADDR_WIDTH-1:0] src_addr;
    logic [ADDR_WIDTH-1:0] dst_addr;
    logic [BURST_LEN-1:0]  burst_len;
    logic                 done;
    logic [ADDR_WIDTH-1:0] curr_src_addr;
    logic [ADDR_WIDTH-1:0] curr_dst_addr;
    logic [BURST_LEN-1:0]  curr_burst_len;
    logic                 read_en;
    logic                 write_en;

    dma_controller #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .BURST_LEN(BURST_LEN)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .src_addr(src_addr),
        .dst_addr(dst_addr),
        .burst_len(burst_len),
        .done(done),
        .curr_src_addr(curr_src_addr),
        .curr_dst_addr(curr_dst_addr),
        .curr_burst_len(curr_burst_len),
        .read_en(read_en),
        .write_en(write_en)
    );

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        start = 1'b0;
        src_addr = 32'h0000_0000;
        dst_addr = 32'h1000_0000;
        burst_len = BURST_LEN'(4);

        #100 rst_n = 1'b1;
        #10 start = 1'b1;
        #10 start = 1'b0;

        wait (done);

        if (curr_src_addr == src_addr + BURST_LEN * DATA_WIDTH/8 &&
            curr_dst_addr == dst_addr + BURST_LEN * DATA_WIDTH/8 &&
            curr_burst_len == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end

        $finish;
    end

    always #5 clk = ~clk;
endmodule