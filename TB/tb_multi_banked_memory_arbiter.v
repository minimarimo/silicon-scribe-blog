`timescale 1ns/1ps

module memory_arbiter_tb;
    parameter NUM_BANKS = 4;
    parameter ADDR_WIDTH = 16;
    parameter DATA_WIDTH = 32;

    logic clk, rst_n;
    logic [NUM_BANKS-1:0] m_req;
    logic [NUM_BANKS-1:0][ADDR_WIDTH-1:0] m_addr;
    logic [NUM_BANKS-1:0] m_wr;
    logic [NUM_BANKS-1:0][DATA_WIDTH-1:0] m_wdata;
    logic [NUM_BANKS-1:0] m_gnt;
    logic [NUM_BANKS-1:0][DATA_WIDTH-1:0] m_rdata;
    logic [NUM_BANKS-1:0] m_rdy;

    memory_arbiter #(
        .NUM_BANKS(NUM_BANKS),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .m_req(m_req),
        .m_addr(m_addr),
        .m_wr(m_wr),
        .m_wdata(m_wdata),
        .m_gnt(m_gnt),
        .m_rdata(m_rdata),
        .m_rdy(m_rdy)
    );

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        m_req = '0;
        m_addr = '0;
        m_wr = '0;
        m_wdata = '0;

        // Reset
        @(posedge clk);
        rst_n = 1'b1;

        // Test read/write operations
        for (int i = 0; i < NUM_BANKS; i++) begin
            m_req[i] = 1'b1;
            m_addr[i] = i * 1024;
            m_wr[i] = (i % 2 == 0) ? 1'b1 : 1'b0;
            m_wdata[i] = (i % 2 == 0) ? 32'hDEADBEEF : 32'h0;
            @(posedge clk);
            while (!m_rdy[i]) @(posedge clk);
            if (m_wr[i]) begin
                // Check write operation
                if (m_rdata[i] != m_wdata[i]) begin
                    $error("TEST FAILED: Bank %0d write data mismatch", i);
                    $finish;
                end
            end else begin
                // Check read operation
                if (m_rdata[i] == 32'h0) begin
                    $error("TEST FAILED: Bank %0d read data is 0", i);
                    $finish;
                end
            end
            m_req[i] = 1'b0;
        end

        $display("TEST PASSED");
        $finish;
    end

    always #5 clk = ~clk;
endmodule