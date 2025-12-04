`timescale 1ns/1ps

module tb_axi4_lite_slave_if;

    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter CLK_PERIOD = 10;
    
    reg clk;
    reg rst_n;
    
    // AXI4-Lite signals
    reg [ADDR_WIDTH-1:0] awaddr;
    reg [2:0] awprot;
    reg awvalid;
    wire awready;
    
    reg [DATA_WIDTH-1:0] wdata;
    reg [(DATA_WIDTH/8)-1:0] wstrb;
    reg wvalid;
    wire wready;
    
    wire [1:0] bresp;
    wire bvalid;
    reg bready;
    
    reg [ADDR_WIDTH-1:0] araddr;
    reg [2:0] arprot;
    reg arvalid;
    wire arready;
    
    wire [DATA_WIDTH-1:0] rdata;
    wire [1:0] rresp;
    wire rvalid;
    reg rready;
    
    // Memory interface
    wire [ADDR_WIDTH-1:0] mem_addr;
    wire [DATA_WIDTH-1:0] mem_wdata;
    wire [(DATA_WIDTH/8)-1:0] mem_wstrb;
    wire mem_wen;
    wire mem_ren;
    reg [DATA_WIDTH-1:0] mem_rdata;
    reg mem_ready;
    
    // Test variables
    reg [31:0] test_count;
    reg test_passed;
    
    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Watchdog timer
    initial begin
        #1000000; // 1ms timeout
        $display("TEST FAILED - Timeout");
        $finish;
    end
    
    // DUT instantiation
    axi4_lite_slave_if #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .awaddr(awaddr),
        .awprot(awprot),
        .awvalid(awvalid),
        .awready(awready),
        .wdata(wdata),
        .wstrb(wstrb),
        .wvalid(wvalid),
        .wready(wready),
        .bresp(bresp),
        .bvalid(bvalid),
        .bready(bready),
        .araddr(araddr),
        .arprot(arprot),
        .arvalid(arvalid),
        .arready(arready),
        .rdata(rdata),
        .rresp(rresp),
        .rvalid(rvalid),
        .rready(rready),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_wen(mem_wen),
        .mem_ren(mem_ren),
        .mem_rdata(mem_rdata),
        .mem_ready(mem_ready)
    );
    
    // Memory model
    always @(posedge clk) begin
        if (mem_wen || mem_ren) begin
            mem_ready <= 1'b1;
            if (mem_ren) begin
                mem_rdata <= 32'hDEADBEEF; // Test pattern
            end
        end else begin
            mem_ready <= 1'b0;
        end
    end
    
    // Test sequence
    initial begin
        // Initialize
        rst_n = 0;
        awaddr = 0;
        awprot = 0;
        awvalid = 0;
        wdata = 0;
        wstrb = 0;
        wvalid = 0;
        bready = 0;
        araddr = 0;
        arprot = 0;
        arvalid = 0;
        rready = 0;
        mem_rdata = 0;
        mem_ready = 0;
        test_count = 0;
        test_passed = 1;
        
        // Reset
        #(CLK_PERIOD * 5);
        rst_n = 1;
        #(CLK_PERIOD * 2);
        
        // Test 1: Write transaction
        $display("Test 1: Write Transaction");
        awaddr = 32'h1000;
        awvalid = 1;
        wdata = 32'h12345678;
        wstrb = 4'hF;
        wvalid = 1;
        bready = 1;
        
        wait(awready && wready);
        @(posedge clk);
        awvalid = 0;
        wvalid = 0;
        
        wait(bvalid);
        @(posedge clk);
        bready = 0;
        
        if (bresp != 2'b00) begin
            $display("FAIL: Write response error");
            test_passed = 0;
        end
        
        #(CLK_PERIOD * 2);
        
        // Test 2: Read transaction
        $display("Test 2: Read Transaction");
        araddr = 32'h2000;
        arvalid = 1;
        rready = 1;
        
        wait(arready);
        @(posedge clk);
        arvalid = 0;
        
        wait(rvalid);
        @(posedge clk);
        rready = 0;
        
        if (rresp != 2'b00 || rdata != 32'hDEADBEEF) begin
            $display("FAIL: Read response error");
            test_passed = 0;
        end
        
        #(CLK_PERIOD * 5);
        
        // Test completion
        if (test_passed) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        
        $finish;
    end

endmodule