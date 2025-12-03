module tb_fsm_sequence_detector_1101;

    reg clk;
    reg reset;
    reg data_in;
    wire detected;

    // Instantiate the DUT
    fsm_sequence_detector_1101 dut (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .detected(detected)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test variables
    integer i;
    reg test_passed;
    integer detection_count;

    initial begin
        // Initialize
        reset = 1;
        data_in = 0;
        test_passed = 1;
        
        // Wait for a few clock cycles
        repeat(3) @(posedge clk);
        reset = 0;
        
        $display("Starting FSM Sequence Detector 1101 Test");
        
        // Test Case 1: Basic sequence 1101
        $display("Test Case 1: Basic sequence 1101");
        detection_count = 0;
        apply_bit(1); if (detected) detection_count = detection_count + 1;
        apply_bit(1); if (detected) detection_count = detection_count + 1;
        apply_bit(0); if (detected) detection_count = detection_count + 1;
        apply_bit(1); if (detected) detection_count = detection_count + 1;
        
        $display("  Expected: 1, Actual: %0d", detection_count);
        if (detection_count != 1) test_passed = 0;
        
        reset_dut();
        
        // Test Case 2: Multiple sequences 11011101
        $display("Test Case 2: Multiple sequences 11011101");
        detection_count = 0;
        apply_bit(1); if (detected) detection_count = detection_count + 1;
        apply_bit(1); if (detected) detection_count = detection_count + 1;
        apply_bit(0); if (detected) detection_count = detection_count + 1;
        apply_bit(1); if (detected) detection_count = detection_count + 1;
        apply_bit(1); if (detected) detection_count = detection_count + 1;
        apply_bit(1); if (detected) detection_count = detection_count + 1;
        apply_bit(0); if (detected) detection_count = detection_count + 1;
        apply_bit(1); if (detected) detection_count = detection_count + 1;
        
        $display("  Expected: 2, Actual: %0d", detection_count);
        if (detection_count != 2) test_passed = 0;
        
        reset_dut();
        
        // Test Case 3: Overlapping sequences 111011101
        $display("Test Case 3: Overlapping sequences 111011101");
        detection_count = 0;
        apply_bit(1); if (detected) detection_count = detection_count + 1;
        apply_bit(1); if (detected) detection_count = detection_count + 1;
        apply_bit(1); if (detected) detection_count = detection_count + 1;
        apply_bit(0); if (detected) detection_count = detection_count + 1;
        apply_bit(1); if (detected) detection_count = detection_count + 1;
        apply_bit(1); if (detected) detection_count = detection_count + 1;
        apply_bit(1); if (detected) detection_count = detection_count + 1;
        apply_bit(0); if (detected) detection_count = detection_count + 1;
        apply_bit(1); if (detected) detection_count = detection_count + 1;
        
        $display("  Expected: 2, Actual: %0d", detection_count);
        if (detection_count != 2) test_passed = 0;
        
        reset_dut();
        
        // Test Case 4: No sequence present 10101010
        $display("Test Case 4: No sequence present 10101010");
        detection_count = 0;
        apply_bit(1); if (detected) detection_count = detection_count + 1;
        apply_bit(0); if (detected) detection_count = detection_count + 1;
        apply_bit(1); if (detected) detection_count = detection_count + 1;
        apply_bit(0); if (detected) detection_count = detection_count + 1;
        apply_bit(1); if (detected) detection_count = detection_count + 1;
        apply_bit(0); if (detected) detection_count = detection_count + 1;
        apply_bit(1); if (detected) detection_count = detection_count + 1;
        apply_bit(0); if (detected) detection_count = detection_count + 1;
        
        $display("  Expected: 0, Actual: %0d", detection_count);
        if (detection_count != 0) test_passed = 0;
        
        reset_dut();
        
        // Test Case 5: Partial sequences 110110
        $display("Test Case 5: Partial sequences 110110");
        detection_count = 0;
        apply_bit(1); if (detected) detection_count = detection_count + 1;
        apply_bit(1); if (detected) detection_count = detection_count + 1;
        apply_bit(0); if (detected) detection_count = detection_count + 1;
        apply_bit(1); if (detected) detection_count = detection_count + 1;
        apply_bit(1); if (detected) detection_count = detection_count + 1;
        apply_bit(0); if (detected) detection_count = detection_count + 1;
        
        $display("  Expected: 0, Actual: %0d", detection_count);
        if (detection_count != 0) test_passed = 0;
        
        reset_dut();
        
        // Test Case 6: Consecutive 1s followed by sequence 1111101
        $display("Test Case 6: Consecutive 1s followed by sequence 1111101");
        detection_count = 0;
        apply_bit(1); if (detected) detection_count = detection_count + 1;
        apply_bit(1); if (detected) detection_count = detection_count + 1;
        apply_bit(1); if (detected) detection_count = detection_count + 1;
        apply_bit(1); if (detected) detection_count = detection_count + 1;
        apply_bit(1); if (detected) detection_count = detection_count + 1;
        apply_bit(0); if (detected) detection_count = detection_count + 1;
        apply_bit(1); if (detected) detection_count = detection_count + 1;
        
        $display("  Expected: 1, Actual: %0d", detection_count);
        if (detection_count != 1) test_passed = 0;
        
        // Final result
        if (test_passed) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        
        $finish;
    end

    // Task to apply a single bit and wait for clock edge
    task apply_bit;
        input bit_value;
        begin
            data_in = bit_value;
            @(posedge clk);
            #1; // Small delay to allow output to settle
        end
    endtask

    // Task to reset the DUT
    task reset_dut;
        begin
            reset = 1;
            @(posedge clk);
            reset = 0;
            @(posedge clk); // Extra clock to ensure clean state
        end
    endtask

endmodule