module traffic_light_controller_tb;

    reg clk;
    reg reset;
    reg emergency;
    wire [1:0] ns_light;
    wire [1:0] ew_light;

    // Light encoding for checking
    parameter RED = 2'b00;
    parameter YELLOW = 2'b01;
    parameter GREEN = 2'b10;

    // Instantiate the DUT
    traffic_light_controller dut (
        .clk(clk),
        .reset(reset),
        .emergency(emergency),
        .ns_light(ns_light),
        .ew_light(ew_light)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Test variables
    reg test_passed;

    initial begin
        // Initialize
        clk = 0;
        reset = 1;
        emergency = 0;
        test_passed = 1;

        // Reset sequence
        #10;
        reset = 0;
        #10;

        // Test 1: Normal operation sequence
        // Should start with NS_GREEN
        if (ns_light != GREEN || ew_light != RED) begin
            $display("Test 1 Failed: Initial state incorrect");
            test_passed = 0;
        end

        // Wait for NS_GREEN period (8 cycles) and check transition
        repeat(8) @(posedge clk);
        if (ns_light != YELLOW || ew_light != RED) begin
            $display("Test 1 Failed: NS_YELLOW state incorrect");
            test_passed = 0;
        end

        // Wait for NS_YELLOW period (2 cycles) and check transition
        repeat(2) @(posedge clk);
        if (ns_light != RED || ew_light != GREEN) begin
            $display("Test 1 Failed: EW_GREEN state incorrect");
            test_passed = 0;
        end

        // Wait for EW_GREEN period (8 cycles) and check transition
        repeat(8) @(posedge clk);
        if (ns_light != RED || ew_light != YELLOW) begin
            $display("Test 1 Failed: EW_YELLOW state incorrect");
            test_passed = 0;
        end

        // Wait for EW_YELLOW period (2 cycles) and check transition
        repeat(2) @(posedge clk);
        if (ns_light != GREEN || ew_light != RED) begin
            $display("Test 1 Failed: Return to NS_GREEN incorrect");
            test_passed = 0;
        end

        // Test 2: Emergency override
        repeat(3) @(posedge clk);
        emergency = 1;
        
        // Wait one clock cycle for emergency to take effect
        @(posedge clk);
        
        // Should go to emergency state (both RED)
        if (ns_light != RED || ew_light != RED) begin
            $display("Test 2 Failed: Emergency state incorrect");
            test_passed = 0;
        end

        // Wait in emergency state
        repeat(3) @(posedge clk);
        
        // Release emergency and wait for timeout
        emergency = 0;
        repeat(4) @(posedge clk);
        
        // Should return to NS_GREEN after emergency timeout
        if (ns_light != GREEN || ew_light != RED) begin
            $display("Test 2 Failed: Post-emergency state incorrect");
            test_passed = 0;
        end

        // Test 3: Reset functionality
        repeat(5) @(posedge clk);
        reset = 1;
        @(posedge clk);
        reset = 0;
        @(posedge clk);
        
        // Should return to initial state
        if (ns_light != GREEN || ew_light != RED) begin
            $display("Test 3 Failed: Reset state incorrect");
            test_passed = 0;
        end

        // Final result
        #50;
        if (test_passed) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end

        $finish;
    end

endmodule