//////////////////////////////////////////////////////////////////////////////
// Testbench: tb_bcd_counter
// Description: Self-checking testbench for BCD counter
//////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module tb_bcd_counter;

    // Testbench signals
    reg        clk;
    reg        rst;
    reg        enable;
    wire [3:0] count;
    wire       carry;

    // Test tracking variables
    integer    error_count;
    integer    test_num;
    integer    i;
    reg [3:0]  expected_count;

    // Instantiate the DUT (Device Under Test)
    bcd_counter dut (
        .clk    (clk),
        .rst    (rst),
        .enable (enable),
        .count  (count),
        .carry  (carry)
    );

    // Clock generation: 10ns period (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Main test sequence
    initial begin
        // Initialize
        error_count = 0;
        test_num = 0;
        rst = 1;
        enable = 0;
        expected_count = 4'd0;

        $display("========================================");
        $display("BCD Counter Testbench Started");
        $display("========================================");

        // Wait for a few clock cycles with reset
        repeat(3) @(posedge clk);

        //--------------------------------------------------
        // Test 1: Check reset functionality
        //--------------------------------------------------
        test_num = 1;
        $display("\nTest %0d: Reset functionality", test_num);
        @(posedge clk);
        #1;
        if (count !== 4'd0) begin
            $display("  ERROR: After reset, count = %0d, expected 0", count);
            error_count = error_count + 1;
        end else begin
            $display("  PASS: Reset works correctly");
        end

        //--------------------------------------------------
        // Test 2: Counter disabled (should hold value)
        //--------------------------------------------------
        test_num = 2;
        $display("\nTest %0d: Counter disabled", test_num);
        rst = 0;
        enable = 0;
        repeat(5) @(posedge clk);
        #1;
        if (count !== 4'd0) begin
            $display("  ERROR: Counter changed while disabled, count = %0d", count);
            error_count = error_count + 1;
        end else begin
            $display("  PASS: Counter holds value when disabled");
        end

        //--------------------------------------------------
        // Test 3: Count from 0 to 9
        //--------------------------------------------------
        test_num = 3;
        $display("\nTest %0d: Count from 0 to 9", test_num);
        enable = 1;
        
        // After enable goes high, on next posedge count will become 1
        // So we check: before first posedge count=0, after first posedge count=1, etc.
        
        // First verify starting at 0
        #1;
        if (count !== 4'd0) begin
            $display("  ERROR: Initial count = %0d, expected 0", count);
            error_count = error_count + 1;
        end
        
        // Now count through 0 to 9 and verify each transition
        for (i = 0; i < 10; i = i + 1) begin
            expected_count = i[3:0];
            // Check current value before clock edge
            if (count !== expected_count) begin
                $display("  ERROR: Before edge %0d, count = %0d, expected = %0d", i, count, expected_count);
                error_count = error_count + 1;
            end
            @(posedge clk);
            #1;
        end
        $display("  Count sequence 0-9 checked");

        //--------------------------------------------------
        // Test 4: Wrap around from 9 to 0
        //--------------------------------------------------
        test_num = 4;
        $display("\nTest %0d: Wrap around from 9 to 0", test_num);
        // After the loop above, count should have wrapped to 0
        if (count !== 4'd0) begin
            $display("  ERROR: Did not wrap to 0, count = %0d", count);
            error_count = error_count + 1;
        end else begin
            $display("  PASS: Counter wrapped from 9 to 0");
        end

        //--------------------------------------------------
        // Test 5: Carry signal check
        //--------------------------------------------------
        test_num = 5;
        $display("\nTest %0d: Carry signal", test_num);
        // Reset and count up to 9
        rst = 1;
        @(posedge clk);
        #1;
        rst = 0;
        enable = 1;
        
        // Count to 9 (need 9 clock edges to go from 0 to 9)
        for (i = 0; i < 9; i = i + 1) begin
            @(posedge clk);
            #1;
        end
        
        if (count !== 4'd9) begin
            $display("  ERROR: Expected count=9, got %0d", count);
            error_count = error_count + 1;
        end else begin
            $display("  PASS: Count reached 9");
        end
        
        if (carry !== 1'b1) begin
            $display("  ERROR: Carry should be 1 when count=9 and enabled");
            error_count = error_count + 1;
        end else begin
            $display("  PASS: Carry asserted at count=9");
        end

        // Check carry is 0 at count=0
        @(posedge clk);
        #1;
        if (count !== 4'd0) begin
            $display("  ERROR: Expected count=0 after wrap, got %0d", count);
            error_count = error_count + 1;
        end
        if (carry !== 1'b0) begin
            $display("  ERROR: Carry should be 0 when count=0");
            error_count = error_count + 1;
        end else begin
            $display("  PASS: Carry deasserted at count=0");
        end

        //--------------------------------------------------
        // Test 6: Reset during counting
        //--------------------------------------------------
        test_num = 6;
        $display("\nTest %0d: Reset during counting", test_num);
        enable = 1;
        repeat(5) @(posedge clk);
        #1;
        rst = 1;
        @(posedge clk);
        #1;
        if (count !== 4'd0) begin
            $display("  ERROR: Reset during count failed, count = %0d", count);
            error_count = error_count + 1;
        end else begin
            $display("  PASS: Reset during counting works");
        end
        rst = 0;

        //--------------------------------------------------
        // Test 7: Multiple full cycles
        //--------------------------------------------------
        test_num = 7;
        $display("\nTest %0d: Multiple full cycles (30 counts)", test_num);
        // Start fresh from reset
        rst = 1;
        @(posedge clk);
        #1;
        rst = 0;
        enable = 1;
        
        // Verify 30 count transitions (3 full cycles)
        for (i = 0; i < 30; i = i + 1) begin
            expected_count = i % 10;
            if (count !== expected_count[3:0]) begin
                $display("  ERROR: At step %0d, count = %0d, expected = %0d", i, count, expected_count);
                error_count = error_count + 1;
            end
            @(posedge clk);
            #1;
        end
        $display("  Multiple cycles completed");

        //--------------------------------------------------
        // Test 8: Disable during counting
        //--------------------------------------------------
        test_num = 8;
        $display("\nTest %0d: Disable during counting", test_num);
        // count should be 0 after 30 transitions (30 mod 10 = 0)
        enable = 0;
        @(posedge clk);
        #1;
        if (count !== 4'd0) begin
            $display("  ERROR: Count changed when disabled, count = %0d", count);
            error_count = error_count + 1;
        end
        repeat(3) @(posedge clk);
        #1;
        if (count !== 4'd0) begin
            $display("  ERROR: Count changed while disabled, count = %0d", count);
            error_count = error_count + 1;
        end else begin
            $display("  PASS: Counter holds when disabled");
        end

        //--------------------------------------------------
        // Final Results
        //--------------------------------------------------
        $display("\n========================================");
        $display("Test Summary");
        $display("========================================");
        
        if (error_count == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
            $display("Total errors: %0d", error_count);
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