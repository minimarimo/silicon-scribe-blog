`timescale 1ns/1ps

module wb_to_axi4_lite_bridge_tb;

    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 32;
    parameter TIMEOUT = 1000;

    // Wishbone Slave Interface
    reg  wb_clk_i;
    reg  wb_rst_i;
    reg  wb_stb_i;
    reg  wb_we_i;
    reg  [ADDR_WIDTH-1:0] wb_adr_i;
    reg  [DATA_WIDTH-1:0] wb_dat_i;
    wire [DATA_WIDTH-1:0] wb_dat_o;
    wire wb_ack_o;

    // AXI4-Lite Master Interface
    wire axi_awvalid;
    wire [ADDR_WIDTH-1:0] axi_awaddr;
    reg  axi_awready;
    wire axi_wvalid;
    wire [DATA_WIDTH-1:0] axi_wdata;
    wire [DATA_WIDTH/8-1:0] axi_wstrb;
    reg  axi_wready;
    reg  axi_bvalid;
    reg  [1:0] axi_bresp;
    wire axi_bready;
    wire axi_arvalid;
    wire [ADDR_WIDTH-1:0] axi_araddr;
    reg  axi_arready;
    reg  axi_rvalid;
    reg  [DATA_WIDTH-1:0] axi_rdata;
    reg  [1:0] axi_rresp;
    wire axi_rready;

    // DUT
    wb_to_axi4_lite_bridge #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .TIMEOUT(TIMEOUT)
    ) dut (
        .wb_clk_i(wb_clk_i),
        .wb_rst_i(wb_rst_i),
        .wb_stb_i(wb_stb_i),
        .wb_we_i(wb_we_i),
        .wb_adr_i(wb_adr_i),
        .wb_dat_i(wb_dat_i),
        .wb_dat_o(wb_dat_o),
        .wb_ack_o(wb_ack_o),
        .axi_awvalid(axi_awvalid),
        .axi_awaddr(axi_awaddr),
        .axi_awready(axi_awready),
        .axi_wvalid(axi_wvalid),
        .axi_wdata(axi_wdata),
        .axi_wstrb(axi_wstrb),
        .axi_wready(axi_wready),
        .axi_bvalid(axi_bvalid),
        .axi_bresp(axi_bresp),
        .axi_bready(axi_bready),
        .axi_arvalid(axi_arvalid),
        .axi_araddr(axi_araddr),
        .axi_arready(axi_arready),
        .axi_rvalid(axi_rvalid),
        .axi_rdata(axi_rdata),
        .axi_rresp(axi_rresp),
        .axi_rready(axi_rready)
    );

    // Testbench
    initial begin
        // Initialize
        wb_clk_i = 0;
        wb_rst_i = 1;
        wb_stb_i = 0;
        wb_we_i = 0;
        wb_adr_i = 0;
        wb_dat_i = 0;
        axi_awready = 0;
        axi_wready = 0;
        axi_bvalid = 0;
        axi_bresp = 0;
        axi_arready = 0;
        axi_rvalid = 0;
        axi_rdata = 0;
        axi_rresp = 0;

        // Reset
        #100 wb_rst_i = 0;

        // Write Test
        #100 wb_stb_i = 1;
        wb_we_i = 1;
        wb_adr_i = 32'h1000;
        wb_dat_i = 32'hDEADBEEF;
        #100 axi_awready = 1;
        axi_wready = 1;
        #100 axi_bvalid = 1;
        axi_bresp = 2'b00;
        #100 wb_stb_i = 0;
        if (wb_ack_o) $display("TEST PASSED: Write");
        else $display("TEST FAILED: Write");

        // Read Test
        #100 wb_stb_i = 1;
        wb_we_i = 0;
        wb_adr_i = 32'h1000;
        #100 axi_arready = 1;
        #100 axi_rvalid = 1;
        axi_rdata = 32'hDEADBEEF;
        axi_rresp = 2'b00;
        #100 wb_stb_i = 0;
        if (wb_dat_o == 32'hDEADBEEF) $display("TEST PASSED: Read");
        else $display("TEST FAILED: Read");

        $finish;
    end

    // Watchdog Timer
    initial #(TIMEOUT*1000) $finish(2);

    // Clock Generation
    always #50 wb_clk_i = ~wb_clk_i;

endmodule