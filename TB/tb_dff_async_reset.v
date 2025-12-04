//-----------------------------------------------------------------------------
// Testbench: tb_d_ff_async_reset
// Description: Self-checking testbench for D Flip-Flop with Async Reset
//-----------------------------------------------------------------------------
`timescale 1ns/1ps

module tb_d_ff_async_reset;

    // Testbench signals
    reg  clk;
    reg  rst;
    reg  d;
    wire q;

    // Test tracking variables
    integer test_count;
    integer pass_count;
    integer fail_count;

    // Instantiate the DUT (Device Under Test)
    d_ff_async_reset dut (
        .clk(clk),
        .rst(rst),
        .d(d),
        .q(q)
    );

    // Clock generation: 10ns period (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Task to check expected output
    task check_output;
        input expected_q;
        input [127:0] test_name;
        begin
            test_count = test_count + 1;
            if (q === expected_q) begin
                $display("[PASS] %0s: q = %b (expected %b)", test_name, q, expected_q);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %0s: q = %b (expected %b)", test_name, q, expected_q);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // Main test sequence
    initial begin
        // Initialize counters
        test_count = 0;
        pass_count = 0;
        fail_count = 0;

        // Initialize inputs
        rst = 0;
        d = 0;

        $display("=========================================");
        $display("D Flip-Flop with Async Reset Testbench");
        $display("=========================================");

        // Wait for initial stabilization
        #10;

        //---------------------------------------------------------------------
        // Test 1: Asynchronous Reset
        //---------------------------------------------------------------------
        $display("\n--- Test 1: Asynchronous Reset ---");
        rst = 1;
        #3;  // Reset should work immediately (not waiting for clock)
        check_output(1'b0, "Async reset active");
        
        // Keep reset active for a while
        #10;
        check_output(1'b0, "Reset held active");

        //---------------------------------------------------------------------
        // Test 2: Release Reset and Load D=1
        //---------------------------------------------------------------------
        $display("\n--- Test 2: Release Reset, Load D=1 ---");
        rst = 0;
        d = 1;
        @(posedge clk);
        #1;  // Small delay after clock edge
        check_output(1'b1, "Load D=1 after reset release");

        //---------------------------------------------------------------------
        // Test 3: Load D=0
        //---------------------------------------------------------------------
        $display("\n--- Test 3: Load D=0 ---");
        d = 0;
        @(posedge clk);
        #1;
        check_output(1'b0, "Load D=0");

        //---------------------------------------------------------------------
        // Test 4: Load D=1 again
        //---------------------------------------------------------------------
        $display("\n--- Test 4: Load D=1 again ---");
        d = 1;
        @(posedge clk);
        #1;
        check_output(1'b1, "Load D=1 again");

        //---------------------------------------------------------------------
        // Test 5: Async Reset while Q=1 (mid-cycle reset)
        //---------------------------------------------------------------------
        $display("\n--- Test 5: Async Reset mid-cycle ---");
        // Q should be 1 now, apply reset asynchronously
        #3;  // Wait a bit (not at clock edge)
        rst = 1;
        #2;  // Reset should take effect immediately
        check_output(1'b0, "Async reset mid-cycle");

        //---------------------------------------------------------------------
        // Test 6: D changes during reset (should be ignored)
        //---------------------------------------------------------------------
        $display("\n--- Test 6: D changes during reset ---");
        d = 1;
        @(posedge clk);
        #1;
        check_output(1'b0, "D=1 ignored during reset");
        
        d = 0;
        @(posedge clk);
        #1;
        check_output(1'b0, "D=0 during reset");

        //---------------------------------------------------------------------
        // Test 7: Release reset and verify normal operation
        //---------------------------------------------------------------------
        $display("\n--- Test 7: Normal operation after reset ---");
        rst = 0;
        d = 1;
        @(posedge clk);
        #1;
        check_output(1'b1, "Normal op: D=1");

        d = 0;
        @(posedge clk);
        #1;
        check_output(1'b0, "Normal op: D=0");

        d = 1;
        @(posedge clk);
        #1;
        check_output(1'b1, "Normal op: D=1 again");

        //---------------------------------------------------------------------
        // Test 8: Data hold (D changes between clock edges)
        //---------------------------------------------------------------------
        $display("\n--- Test 8: Data hold test ---");
        d = 0;
        #2;  // Change D between clock edges
        d = 1;
        #2;
        d = 0;  // D=0 just before clock edge
        @(posedge clk);
        #1;
        check_output(1'b0, "Data sampled at clock edge");

        //---------------------------------------------------------------------
        // Print Test Summary
        //---------------------------------------------------------------------
        #20;
        $display("\n=========================================");
        $display("Test Summary");
        $display("=========================================");
        $display("Total Tests: %0d", test_count);
        $display("Passed:      %0d", pass_count);
        $display("Failed:      %0d", fail_count);
        $display("=========================================");

        if (fail_count == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end

        $display("=========================================\n");
        
        #10;
        $finish;
    end

    // Optional: Timeout watchdog
    initial begin
        #10000;
        $display("ERROR: Simulation timeout!");
        $display("TEST FAILED");
        $finish;
    end

endmodule