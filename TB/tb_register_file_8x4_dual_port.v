module tb_dual_port_register_file_8x4;

    // Testbench signals
    reg clk;
    reg rst_n;
    reg wr_en;
    reg [2:0] wr_addr;
    reg [3:0] wr_data;
    reg [2:0] rd_addr_a;
    reg [2:0] rd_addr_b;
    wire [3:0] rd_data_a;
    wire [3:0] rd_data_b;
    
    // Test control variables
    reg test_passed;
    integer i;
    
    // Instantiate the DUT
    dual_port_register_file_8x4 dut (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .wr_addr(wr_addr),
        .wr_data(wr_data),
        .rd_addr_a(rd_addr_a),
        .rd_addr_b(rd_addr_b),
        .rd_data_a(rd_data_a),
        .rd_data_b(rd_data_b)
    );
    
    // Clock generation
    always #5 clk = ~clk;
    
    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        wr_en = 0;
        wr_addr = 0;
        wr_data = 0;
        rd_addr_a = 0;
        rd_addr_b = 0;
        test_passed = 1;
        
        // Reset sequence
        #10;
        rst_n = 1;
        #10;
        
        // Test 1: Check reset state - all registers should be 0
        for (i = 0; i < 8; i = i + 1) begin
            rd_addr_a = i;
            #1;
            if (rd_data_a !== 4'b0000) begin
                test_passed = 0;
                $display("FAIL: Register %0d not reset properly. Expected: 0000, Got: %b", i, rd_data_a);
            end
        end
        
        // Test 2: Write to all registers with unique patterns
        for (i = 0; i < 8; i = i + 1) begin
            @(posedge clk);
            wr_en = 1;
            wr_addr = i;
            wr_data = i + 1; // Write pattern: reg0=1, reg1=2, ..., reg7=8
            @(posedge clk);
            wr_en = 0;
        end
        
        // Test 3: Read back all written values using port A
        #10;
        for (i = 0; i < 8; i = i + 1) begin
            rd_addr_a = i;
            #1;
            if (rd_data_a !== (i + 1)) begin
                test_passed = 0;
                $display("FAIL: Port A read from register %0d. Expected: %0d, Got: %0d", i, i+1, rd_data_a);
            end
        end
        
        // Test 4: Read back all written values using port B
        for (i = 0; i < 8; i = i + 1) begin
            rd_addr_b = i;
            #1;
            if (rd_data_b !== (i + 1)) begin
                test_passed = 0;
                $display("FAIL: Port B read from register %0d. Expected: %0d, Got: %0d", i, i+1, rd_data_b);
            end
        end
        
        // Test 5: Simultaneous dual-port read
        rd_addr_a = 3'b010; // Register 2
        rd_addr_b = 3'b101; // Register 5
        #1;
        if (rd_data_a !== 4'd3 || rd_data_b !== 4'd6) begin
            test_passed = 0;
            $display("FAIL: Simultaneous read. Port A (reg2): Expected 3, Got %0d. Port B (reg5): Expected 6, Got %0d", rd_data_a, rd_data_b);
        end
        
        // Test 6: Write while reading (write-through test)
        rd_addr_a = 3'b011; // Read from register 3
        rd_addr_b = 3'b011; // Read from register 3 on both ports
        @(posedge clk);
        wr_en = 1;
        wr_addr = 3'b011; // Write to register 3
        wr_data = 4'b1111; // New value
        @(posedge clk);
        wr_en = 0;
        #1;
        if (rd_data_a !== 4'b1111 || rd_data_b !== 4'b1111) begin
            test_passed = 0;
            $display("FAIL: Write-through test. Expected both ports to read 1111. Port A: %b, Port B: %b", rd_data_a, rd_data_b);
        end
        
        // Test 7: Address boundary test
        rd_addr_a = 3'b000; // Register 0
        rd_addr_b = 3'b111; // Register 7
        #1;
        if (rd_data_a !== 4'd1 || rd_data_b !== 4'd8) begin
            test_passed = 0;
            $display("FAIL: Boundary test. Port A (reg0): Expected 1, Got %0d. Port B (reg7): Expected 8, Got %0d", rd_data_a, rd_data_b);
        end
        
        // Final result
        #10;
        if (test_passed) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        
        $finish;
    end

endmodule