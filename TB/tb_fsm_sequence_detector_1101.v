// Testbench for FSM Sequence Detector 1101
`timescale 1ns/1ps

module seq_detector_1101_tb;

    // Testbench signals
    reg  clk;
    reg  rst_n;
    reg  din;
    wire detected;

    // Test tracking
    integer test_count;
    integer pass_count;
    integer fail_count;
    integer i;

    // Test input sequence stored as array for clarity
    reg [0:16] test_sequence;
    reg [0:16] expected_output;
    integer seq_length;

    // Instantiate DUT
    seq_detector_1101 dut (
        .clk(clk),
        .rst_n(rst_n),
        .din(din),
        .detected(detected)
    );

    // Clock generation - 10ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Main test procedure
    initial begin
        // Initialize
        test_count = 0;
        pass_count = 0;
        fail_count = 0;
        din = 0;
        rst_n = 1;

        // Test sequence: 0 1 1 0 1 1 1 0 1 0 1 1 0 1 1 0 1
        // Positions:     0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16
        // 
        // State trace:
        // i=0: din=0, state=IDLE->IDLE, detected=0
        // i=1: din=1, state=IDLE->S_1, detected=0
        // i=2: din=1, state=S_1->S_11, detected=0
        // i=3: din=0, state=S_11->S_110, detected=0
        // i=4: din=1, state=S_110->S_1, detected=1 (pattern 1101 at positions 1-4)
        // i=5: din=1, state=S_1->S_11, detected=0
        // i=6: din=1, state=S_11->S_11, detected=0
        // i=7: din=0, state=S_11->S_110, detected=0
        // i=8: din=1, state=S_110->S_1, detected=1 (pattern 1101 at positions 5-8)
        // i=9: din=0, state=S_1->IDLE, detected=0
        // i=10: din=1, state=IDLE->S_1, detected=0
        // i=11: din=1, state=S_1->S_11, detected=0
        // i=12: din=0, state=S_11->S_110, detected=0
        // i=13: din=1, state=S_110->S_1, detected=1 (pattern 1101 at positions 10-13)
        // i=14: din=1, state=S_1->S_11, detected=0
        // i=15: din=0, state=S_11->S_110, detected=0
        // i=16: din=1, state=S_110->S_1, detected=1 (pattern 1101 at positions 13-16, overlapping)

        test_sequence   = 17'b0_1_1_0_1_1_1_0_1_0_1_1_0_1_1_0_1;
        expected_output = 17'b0_0_0_0_1_0_0_0_1_0_0_0_0_1_0_0_1;
        seq_length = 17;

        $display("========================================");
        $display("FSM Sequence Detector 1101 - Testbench");
        $display("========================================");

        // Apply reset
        $display("\n[INFO] Applying reset...");
        @(negedge clk);
        rst_n = 0;
        @(negedge clk);
        @(negedge clk);
        rst_n = 1;
        @(negedge clk);

        // Check reset state
        test_count = test_count + 1;
        if (detected == 0) begin
            $display("[PASS] Reset test - detected is 0 after reset");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Reset test - detected should be 0 after reset, got %b", detected);
            fail_count = fail_count + 1;
        end

        // Run main sequence test
        $display("\n[INFO] Running sequence test...");
        $display("Input sequence: 0 1 1 0 1 1 1 0 1 0 1 1 0 1 1 0 1");
        $display("Expected detections at bit positions: 4, 8, 13, 16");

        for (i = 0; i < seq_length; i = i + 1) begin
            @(negedge clk);
            din = test_sequence[i];
            
            @(posedge clk);
            #1; // Small delay to let output settle
            
            test_count = test_count + 1;
            
            if (detected == expected_output[i]) begin
                if (detected)
                    $display("[PASS] Bit %0d: din=%b, detected=%b (Pattern found!)", i, din, detected);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] Bit %0d: din=%b, detected=%b, expected=%b", 
                         i, din, detected, expected_output[i]);
                fail_count = fail_count + 1;
            end
        end

        // Additional test: No false positives with all zeros
        $display("\n[INFO] Testing all zeros (no false positives)...");
        for (i = 0; i < 8; i = i + 1) begin
            @(negedge clk);
            din = 0;
            @(posedge clk);
            #1;
            test_count = test_count + 1;
            if (detected == 0) begin
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] False positive detected with all zeros at cycle %0d", i);
                fail_count = fail_count + 1;
            end
        end

        // Additional test: Pattern after reset
        $display("\n[INFO] Testing pattern immediately after reset...");
        @(negedge clk);
        rst_n = 0;
        @(negedge clk);
        rst_n = 1;
        
        // Send 1101
        @(negedge clk); din = 1; @(posedge clk); #1;
        test_count = test_count + 1;
        if (detected == 0) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        
        @(negedge clk); din = 1; @(posedge clk); #1;
        test_count = test_count + 1;
        if (detected == 0) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        
        @(negedge clk); din = 0; @(posedge clk); #1;
        test_count = test_count + 1;
        if (detected == 0) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        
        @(negedge clk); din = 1; @(posedge clk); #1;
        test_count = test_count + 1;
        if (detected == 1) begin
            $display("[PASS] Pattern 1101 detected correctly after reset");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Pattern 1101 not detected after reset");
            fail_count = fail_count + 1;
        end

        // Additional test: Overlapping pattern 11101
        $display("\n[INFO] Testing overlapping pattern 11101...");
        @(negedge clk);
        rst_n = 0;
        @(negedge clk);
        rst_n = 1;
        
        // Send 11101 - should detect at position 4 (the last 1)
        @(negedge clk); din = 1; @(posedge clk); #1; // S_1
        @(negedge clk); din = 1; @(posedge clk); #1; // S_11
        @(negedge clk); din = 1; @(posedge clk); #1; // S_11 (stay)
        @(negedge clk); din = 0; @(posedge clk); #1; // S_110
        @(negedge clk); din = 1; @(posedge clk); #1; // S_1, detected=1
        
        test_count = test_count + 1;
        if (detected == 1) begin
            $display("[PASS] Overlapping pattern 11101 detected correctly");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Overlapping pattern 11101 not detected");
            fail_count = fail_count + 1;
        end

        // Print final results
        $display("\n========================================");
        $display("Test Summary:");
        $display("  Total tests: %0d", test_count);
        $display("  Passed:      %0d", pass_count);
        $display("  Failed:      %0d", fail_count);
        $display("========================================");

        if (fail_count == 0) begin
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
        $display("[ERROR] Simulation timeout!");
        $display("TEST FAILED");
        $finish;
    end

endmodule