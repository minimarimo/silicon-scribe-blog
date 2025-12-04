`timescale 1ns/1ps

module apb3_bridge_tb;
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;

    reg                  pclk;
    reg                  presetn;
    reg [ADDR_WIDTH-1:0] paddr;
    reg [DATA_WIDTH-1:0] pwdata;
    reg                  pwrite;
    reg                  psel;
    reg                  penable;
    wire [DATA_WIDTH-1:0] prdata;
    wire                  pready;
    wire                  pslverr;

    apb3_bridge #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .pclk(pclk),
        .presetn(presetn),
        .paddr(paddr),
        .pwdata(pwdata),
        .pwrite(pwrite),
        .psel(psel),
        .penable(penable),
        .prdata(prdata),
        .pready(pready),
        .pslverr(pslverr)
    );

    initial begin
        pclk = 1'b0;
        presetn = 1'b0;
        paddr = {ADDR_WIDTH{1'b0}};
        pwdata = {DATA_WIDTH{1'b0}};
        pwrite = 1'b0;
        psel = 1'b0;
        penable = 1'b0;

        #100 presetn = 1'b1;

        // Write test
        @(posedge pclk) begin
            paddr = 32'h0000_0000;
            pwdata = 32'hDEAD_BEEF;
            pwrite = 1'b1;
            psel = 1'b1;
            penable = 1'b1;
        end
        @(posedge pclk) begin
            pwrite = 1'b0;
            psel = 1'b0;
            penable = 1'b0;
        end

        // Read test
        @(posedge pclk) begin
            paddr = 32'h0000_0000;
            pwrite = 1'b0;
            psel = 1'b1;
            penable = 1'b1;
        end
        @(posedge pclk) begin
            pwrite = 1'b0;
            psel = 1'b0;
            penable = 1'b0;
        end

        if (prdata === 32'hDEAD_BEEF) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end

        #100 $finish;
    end

    always #5 pclk = ~pclk;

    // Watchdog timer
    initial begin
        #1000 $display("TIMEOUT: TEST FAILED");
        $finish;
    end

endmodule