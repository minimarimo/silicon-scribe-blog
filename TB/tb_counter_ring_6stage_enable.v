module tb_fsm_sequence_detector_1101;

    reg clk;
    reg rst_n;
    reg data_in;
    wire detected;
    
    // Test variables
    integer test_case;
    integer detection_count;
    integer expected_count;
    reg test_passed;
    
    // Instantiate DUT
    fsm_sequence_detector_1101 dut (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .detected(detected)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Task to send a bit sequence and count detections
    task send_sequence(input [31:0] sequence, input integer length, input integer expected);
        integer i;
        begin
            detection_count = 0;
            
            // Send each bit and check for detection on next clock edge
            for (i = length-1; i >= 0; i = i - 1) begin
                data_in = sequence[i];
                @(posedge clk);
                // Check detection after the clock edge
                if (detected) begin
                    detection_count = detection_count + 1;
                    $display("    Detection at bit position %0d", length-1-i);
                end
            end
            
            $display("  Expected: %0d, Actual: %0d", expected, detection_count);
            
            if (detection_count != expected) begin
                test_passed = 0;
            end
        end
    endtask
    
    // Main test
    initial begin
        test_passed = 1;
        test_case = 0;
        
        // Initialize
        rst_n = 0;
        data_in = 0;
        
        repeat(3) @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        
        $display("Starting FSM Sequence Detector 1101 Test");
        
        // Test Case 1: Basic sequence 1101
        test_case = 1;
        $display("Test Case 1: Basic sequence 1101");
        send_sequence(32'b1101, 4, 1);
        
        // Reset between tests
        rst_n = 0;
        @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        
        // Test Case 2: Multiple sequences 11011101
        test_case = 2;
        $display("Test Case 2: Multiple sequences 11011101");
        send_sequence(32'b11011101, 8, 2);
        
        // Reset between tests
        rst_n = 0;
        @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        
        // Test Case 3: Overlapping sequences 111011101
        test_case = 3;
        $display("Test Case 3: Overlapping sequences 111011101");
        send_sequence(32'b111011101, 9, 2);
        
        // Reset between tests
        rst_n = 0;
        @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        
        // Test Case 4: No sequence present 10101010
        test_case = 4;
        $display("Test Case 4: No sequence present 10101010");
        send_sequence(32'b10101010, 8, 0);
        
        // Reset between tests
        rst_n = 0;
        @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        
        // Test Case 5: Partial sequences 110110
        test_case = 5;
        $display("Test Case 5: Partial sequences 110110");
        send_sequence(32'b110110, 6, 0);
        
        // Reset between tests
        rst_n = 0;
        @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        
        // Test Case 6: Consecutive 1s followed by sequence 1111101
        test_case = 6;
        $display("Test Case 6: Consecutive 1s followed by sequence 1111101");
        send_sequence(32'b1111101, 7, 1);
        
        // Final result
        if (test_passed) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        
        $finish;
    end
    
    // Timeout watchdog
    initial begin
        #2000;
        $display("TEST FAILED: Timeout");
        $finish;
    end

endmodule