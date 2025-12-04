// Testbench for 8-bit Ring Counter
// Self-checking testbench that verifies ring counter operation

`timescale 1ns / 1ps

module ring_counter_8bit_tb;

    // Testbench signals
    reg        clk;
    reg        rst_n;
    reg        enable;
    wire [7:0] q;

    // Test tracking variables
    integer    error_count;
    integer    test_num;
    reg [7:0]  expected_value;
    integer    i;
    integer    bit_count;

    // Instantiate the Device Under Test (DUT)
    ring_counter_8bit dut (
        .clk    (clk),
        .rst_n  (rst_n),
        .enable (enable),
        .q      (q)
    );

    // Clock generation: 10ns period (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Function to count ones in an 8-bit value (Verilog-2001 compatible)
    function integer count_ones;
        input [7:0] val;
        integer j;
        begin
            count_ones = 0;
            for (j = 0; j < 8; j = j + 1) begin
                if (val[j] == 1'b1)
                    count_ones = count_ones + 1;
            end
        end
    endfunction

    // Main test sequence
    initial begin
        // Initialize signals
        error_count = 0;
        test_num = 0;
        rst_n = 1;
        enable = 0;

        // Display header
        $display("========================================");
        $display("  8-bit Ring Counter Testbench Start");
        $display("========================================");

        // Test 1: Reset functionality
        test_num = 1;
        $display("\nTest %0d: Reset functionality", test_num);
        @(negedge clk);
        rst_n = 0;
        @(negedge clk);
        @(posedge clk);
        #1;
        expected_value = 8'b00000001;
        if (q !== expected_value) begin
            $display("  FAIL: After reset, q = %b, expected %b", q, expected_value);
            error_count = error_count + 1;
        end else begin
            $display("  PASS: Reset value correct, q = %b", q);
        end

        // Release reset
        @(negedge clk);
        rst_n = 1;

        // Test 2: Counter disabled (should hold value)
        test_num = 2;
        $display("\nTest %0d: Counter disabled - hold value", test_num);
        enable = 0;
        expected_value = q;
        repeat(3) @(posedge clk);
        #1;
        if (q !== expected_value) begin
            $display("  FAIL: Counter changed when disabled, q = %b, expected %b", q, expected_value);
            error_count = error_count + 1;
        end else begin
            $display("  PASS: Counter held value when disabled, q = %b", q);
        end

        // Test 3: Full ring rotation (8 cycles should return to initial state)
        test_num = 3;
        $display("\nTest %0d: Full ring rotation (8 cycles)", test_num);
        enable = 1;
        expected_value = 8'b00000001;
        
        $display("  Starting value: %b", q);
        
        // Check each step of the rotation
        for (i = 0; i < 8; i = i + 1) begin
            @(posedge clk);
            #1;
            expected_value = {expected_value[6:0], expected_value[7]};
            $display("  Cycle %0d: q = %b, expected = %b", i+1, q, expected_value);
            if (q !== expected_value) begin
                $display("    FAIL at cycle %0d", i+1);
                error_count = error_count + 1;
            end
        end
        
        // After 8 cycles, should be back to initial value
        if (q === 8'b00000001) begin
            $display("  PASS: Returned to initial state after 8 cycles");
        end else begin
            $display("  FAIL: Did not return to initial state");
            error_count = error_count + 1;
        end

        // Test 4: One-hot check during rotation
        test_num = 4;
        $display("\nTest %0d: One-hot property verification", test_num);
        @(negedge clk);
        rst_n = 0;
        @(negedge clk);
        rst_n = 1;
        enable = 1;
        
        for (i = 0; i < 16; i = i + 1) begin
            @(posedge clk);
            #1;
            // Check one-hot: exactly one bit should be set
            bit_count = count_ones(q);
            if (bit_count !== 1) begin
                $display("  FAIL: Not one-hot at cycle %0d, q = %b, bit_count = %0d", i, q, bit_count);
                error_count = error_count + 1;
            end
        end
        $display("  PASS: One-hot property maintained for 16 cycles");

        // Test 5: Asynchronous reset during operation
        test_num = 5;
        $display("\nTest %0d: Asynchronous reset during operation", test_num);
        enable = 1;
        repeat(3) @(posedge clk);
        #2;
        rst_n = 0;
        #2;
        if (q !== 8'b00000001) begin
            $display("  FAIL: Async reset failed, q = %b", q);
            error_count = error_count + 1;
        end else begin
            $display("  PASS: Async reset worked correctly, q = %b", q);
        end
        @(negedge clk);
        rst_n = 1;

        // Test 6: Enable toggle during operation
        test_num = 6;
        $display("\nTest %0d: Enable toggle during operation", test_num);
        enable = 1;
        @(posedge clk);
        #1;
        expected_value = q;
        @(posedge clk);
        #1;
        expected_value = {expected_value[6:0], expected_value[7]};
        
        // Disable and check hold
        enable = 0;
        @(posedge clk);
        #1;
        if (q !== expected_value) begin
            $display("  FAIL: Value changed when disabled");
            error_count = error_count + 1;
        end else begin
            $display("  PASS: Value held when disabled, q = %b", q);
        end

        // Final results
        $display("\n========================================");
        $display("  Test Summary");
        $display("========================================");
        $display("  Total errors: %0d", error_count);
        
        if (error_count == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        
        $display("========================================\n");
        
        #20;
        $finish;
    end

    // Timeout watchdog
    initial begin
        #10000;
        $display("ERROR: Simulation timeout!");
        $display("TEST FAILED");
        $finish;
    end

endmodule