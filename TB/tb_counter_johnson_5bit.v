// Testbench for 5-bit Johnson Counter
`timescale 1ns/1ps

module johnson_counter_5bit_tb;

    // Testbench signals
    reg        clk;
    reg        rst_n;
    reg        enable;
    wire [4:0] q;

    // Expected sequence for 5-bit Johnson counter (10 states)
    reg [4:0] expected_sequence [0:9];
    
    // Test control variables
    integer i;
    integer error_count;
    reg [4:0] expected_value;
    reg test_passed;

    // Instantiate the DUT (Device Under Test)
    johnson_counter_5bit dut (
        .clk    (clk),
        .rst_n  (rst_n),
        .enable (enable),
        .q      (q)
    );

    // Clock generation - 10ns period (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Initialize expected Johnson counter sequence
    initial begin
        expected_sequence[0] = 5'b00000;
        expected_sequence[1] = 5'b00001;
        expected_sequence[2] = 5'b00011;
        expected_sequence[3] = 5'b00111;
        expected_sequence[4] = 5'b01111;
        expected_sequence[5] = 5'b11111;
        expected_sequence[6] = 5'b11110;
        expected_sequence[7] = 5'b11100;
        expected_sequence[8] = 5'b11000;
        expected_sequence[9] = 5'b10000;
    end

    // Main test sequence
    initial begin
        // Initialize signals
        rst_n = 1;
        enable = 0;
        error_count = 0;
        test_passed = 1;

        $display("========================================");
        $display("  5-bit Johnson Counter Testbench");
        $display("========================================");

        // Test 1: Reset functionality
        $display("\nTest 1: Checking reset functionality...");
        #10;
        rst_n = 0;  // Assert reset
        #20;
        
        if (q !== 5'b00000) begin
            $display("ERROR: Reset failed. Expected 00000, Got %b", q);
            error_count = error_count + 1;
            test_passed = 0;
        end else begin
            $display("PASS: Reset works correctly. q = %b", q);
        end

        // Release reset
        #10;
        rst_n = 1;
        #10;

        // Test 2: Enable disabled - counter should hold
        $display("\nTest 2: Checking enable=0 (counter should hold)...");
        enable = 0;
        @(posedge clk);
        #1;
        
        if (q !== 5'b00000) begin
            $display("ERROR: Counter changed when disabled. Got %b", q);
            error_count = error_count + 1;
            test_passed = 0;
        end else begin
            $display("PASS: Counter holds when disabled. q = %b", q);
        end

        // Test 3: Full sequence test - run through all 10 states twice
        $display("\nTest 3: Checking full Johnson counter sequence...");
        enable = 1;
        
        // Check initial state
        #1;
        if (q !== expected_sequence[0]) begin
            $display("ERROR at state 0: Expected %b, Got %b", expected_sequence[0], q);
            error_count = error_count + 1;
            test_passed = 0;
        end else begin
            $display("State 0: q = %b (correct)", q);
        end

        // Run through sequence twice (20 clock cycles)
        for (i = 1; i < 20; i = i + 1) begin
            @(posedge clk);
            #1;
            expected_value = expected_sequence[i % 10];
            
            if (q !== expected_value) begin
                $display("ERROR at state %0d: Expected %b, Got %b", i, expected_value, q);
                error_count = error_count + 1;
                test_passed = 0;
            end else begin
                $display("State %0d: q = %b (correct)", i % 10, q);
            end
        end

        // Test 4: Reset during operation
        $display("\nTest 4: Checking reset during operation...");
        @(posedge clk);
        @(posedge clk);
        rst_n = 0;
        #1;
        
        if (q !== 5'b00000) begin
            $display("ERROR: Async reset failed during operation. Got %b", q);
            error_count = error_count + 1;
            test_passed = 0;
        end else begin
            $display("PASS: Async reset works during operation. q = %b", q);
        end

        // Test 5: Resume after reset
        $display("\nTest 5: Checking resume after reset...");
        #20;
        rst_n = 1;
        @(posedge clk);
        #1;
        
        if (q !== 5'b00001) begin
            $display("ERROR: Resume after reset failed. Expected 00001, Got %b", q);
            error_count = error_count + 1;
            test_passed = 0;
        end else begin
            $display("PASS: Resume after reset works. q = %b", q);
        end

        // Final results
        $display("\n========================================");
        $display("  Test Summary");
        $display("========================================");
        $display("Total errors: %0d", error_count);
        
        if (error_count == 0 && test_passed) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        
        $display("========================================\n");
        
        #50;
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