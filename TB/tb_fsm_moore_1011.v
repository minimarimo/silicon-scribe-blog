module tb_sequence_detector_1011;

    reg clk;
    reg reset;
    reg data_in;
    wire detected;

    // Instantiate the DUT
    sequence_detector_1011 dut (
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

    initial begin
        test_passed = 1'b1;
        
        // Initialize
        reset = 1;
        data_in = 0;
        #10;
        reset = 0;
        #10;

        // Test case 1: Basic sequence 1011
        $display("Test case 1: Basic sequence 1011");
        data_in = 1; #10; // 1
        data_in = 0; #10; // 0  
        data_in = 1; #10; // 1
        data_in = 1; #10; // 1 - should detect here
        if (detected !== 1'b1) begin
            $display("Test case 1 failed: Expected detection after 1011");
            test_passed = 1'b0;
        end
        
        // Reset for next test
        reset = 1;
        #10;
        reset = 0;
        #10;

        // Test case 2: Overlapping sequences 101101011
        $display("Test case 2: Overlapping sequences 101101011");
        data_in = 1; #10; // 1
        data_in = 0; #10; // 0
        data_in = 1; #10; // 1
        data_in = 1; #10; // 1 - first 1011 detected
        if (detected !== 1'b1) begin
            $display("Test case 2 failed: Expected first detection");
            test_passed = 1'b0;
        end
        data_in = 0; #10; // 0
        data_in = 1; #10; // 1
        data_in = 0; #10; // 0
        data_in = 1; #10; // 1
        data_in = 1; #10; // 1 - second 1011 detected
        if (detected !== 1'b1) begin
            $display("Test case 2 failed: Expected second detection");
            test_passed = 1'b0;
        end

        // Reset for next test
        reset = 1;
        #10;
        reset = 0;
        #10;

        // Test case 3: No sequence present 110010
        $display("Test case 3: No sequence 110010");
        data_in = 1; #10; // 1
        data_in = 1; #10; // 1
        data_in = 0; #10; // 0
        data_in = 0; #10; // 0
        data_in = 1; #10; // 1
        data_in = 0; #10; // 0
        if (detected !== 1'b0) begin
            $display("Test case 3 failed: Unexpected detection");
            test_passed = 1'b0;
        end

        // Reset for next test
        reset = 1;
        #10;
        reset = 0;
        #10;

        // Test case 4: Multiple consecutive 1s followed by 011 (11110011)
        $display("Test case 4: Sequence 11110011");
        data_in = 1; #10; // 1
        data_in = 1; #10; // 1
        data_in = 1; #10; // 1
        data_in = 1; #10; // 1
        data_in = 0; #10; // 0
        data_in = 0; #10; // 0
        data_in = 1; #10; // 1
        data_in = 1; #10; // 1 - should NOT detect (sequence is 1011, not 0011)
        if (detected !== 1'b0) begin
            $display("Test case 4 failed: Unexpected detection");
            test_passed = 1'b0;
        end

        // Reset for next test
        reset = 1;
        #10;
        reset = 0;
        #10;

        // Test case 5: Correct sequence after multiple 1s (111011)
        $display("Test case 5: Sequence 111011");
        data_in = 1; #10; // 1
        data_in = 1; #10; // 1
        data_in = 1; #10; // 1
        data_in = 0; #10; // 0
        data_in = 1; #10; // 1
        data_in = 1; #10; // 1 - should detect (last 4 bits are 1011)
        if (detected !== 1'b1) begin
            $display("Test case 5 failed: Expected detection");
            test_passed = 1'b0;
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