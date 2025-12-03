// Testbench for 74LS32 Quad 2-input OR Gate
module tb_ls32_quad_or;

    // Test signals
    reg a1, b1, a2, b2, a3, b3, a4, b4;
    wire y1, y2, y3, y4;
    
    // Test variables
    reg [7:0] test_inputs;
    reg [3:0] expected_outputs;
    reg [3:0] actual_outputs;
    integer i;
    reg test_passed;

    // Instantiate the DUT
    ls32_quad_or dut (
        .a1(a1), .b1(b1), .y1(y1),
        .a2(a2), .b2(b2), .y2(y2),
        .a3(a3), .b3(b3), .y3(y3),
        .a4(a4), .b4(b4), .y4(y4)
    );

    initial begin
        test_passed = 1'b1;
        
        $display("Testing 74LS32 Quad 2-input OR Gate");
        $display("Time\ta1 b1 y1 | a2 b2 y2 | a3 b3 y3 | a4 b4 y4");
        $display("----+----------+----------+----------+----------");
        
        // Test all possible input combinations for each gate
        for (i = 0; i < 256; i = i + 1) begin
            test_inputs = i;
            {a4, b4, a3, b3, a2, b2, a1, b1} = test_inputs;
            
            #1; // Wait for propagation
            
            // Calculate expected outputs
            expected_outputs[0] = a1 | b1;
            expected_outputs[1] = a2 | b2;
            expected_outputs[2] = a3 | b3;
            expected_outputs[3] = a4 | b4;
            
            // Get actual outputs
            actual_outputs = {y4, y3, y2, y1};
            
            // Display current test
            $display("%4t\t%b  %b  %b  | %b  %b  %b  | %b  %b  %b  | %b  %b  %b", 
                     $time, a1, b1, y1, a2, b2, y2, a3, b3, y3, a4, b4, y4);
            
            // Check if outputs match expected values
            if (actual_outputs !== expected_outputs) begin
                $display("ERROR: Expected %b, got %b", expected_outputs, actual_outputs);
                test_passed = 1'b0;
            end
        end
        
        // Additional focused tests for each gate
        $display("\nFocused testing for each OR gate:");
        
        // Test Gate 1: 00, 01, 10, 11
        {a1, b1} = 2'b00; {a2, b2, a3, b3, a4, b4} = 6'b000000; #1;
        if (y1 !== 1'b0) test_passed = 1'b0;
        
        {a1, b1} = 2'b01; {a2, b2, a3, b3, a4, b4} = 6'b000000; #1;
        if (y1 !== 1'b1) test_passed = 1'b0;
        
        {a1, b1} = 2'b10; {a2, b2, a3, b3, a4, b4} = 6'b000000; #1;
        if (y1 !== 1'b1) test_passed = 1'b0;
        
        {a1, b1} = 2'b11; {a2, b2, a3, b3, a4, b4} = 6'b000000; #1;
        if (y1 !== 1'b1) test_passed = 1'b0;
        
        // Test Gate 2
        {a2, b2} = 2'b00; {a1, b1, a3, b3, a4, b4} = 6'b000000; #1;
        if (y2 !== 1'b0) test_passed = 1'b0;
        
        {a2, b2} = 2'b01; {a1, b1, a3, b3, a4, b4} = 6'b000000; #1;
        if (y2 !== 1'b1) test_passed = 1'b0;
        
        {a2, b2} = 2'b10; {a1, b1, a3, b3, a4, b4} = 6'b000000; #1;
        if (y2 !== 1'b1) test_passed = 1'b0;
        
        {a2, b2} = 2'b11; {a1, b1, a3, b3, a4, b4} = 6'b000000; #1;
        if (y2 !== 1'b1) test_passed = 1'b0;
        
        // Test Gate 3
        {a3, b3} = 2'b00; {a1, b1, a2, b2, a4, b4} = 6'b000000; #1;
        if (y3 !== 1'b0) test_passed = 1'b0;
        
        {a3, b3} = 2'b01; {a1, b1, a2, b2, a4, b4} = 6'b000000; #1;
        if (y3 !== 1'b1) test_passed = 1'b0;
        
        {a3, b3} = 2'b10; {a1, b1, a2, b2, a4, b4} = 6'b000000; #1;
        if (y3 !== 1'b1) test_passed = 1'b0;
        
        {a3, b3} = 2'b11; {a1, b1, a2, b2, a4, b4} = 6'b000000; #1;
        if (y3 !== 1'b1) test_passed = 1'b0;
        
        // Test Gate 4
        {a4, b4} = 2'b00; {a1, b1, a2, b2, a3, b3} = 6'b000000; #1;
        if (y4 !== 1'b0) test_passed = 1'b0;
        
        {a4, b4} = 2'b01; {a1, b1, a2, b2, a3, b3} = 6'b000000; #1;
        if (y4 !== 1'b1) test_passed = 1'b0;
        
        {a4, b4} = 2'b10; {a1, b1, a2, b2, a3, b3} = 6'b000000; #1;
        if (y4 !== 1'b1) test_passed = 1'b0;
        
        {a4, b4} = 2'b11; {a1, b1, a2, b2, a3, b3} = 6'b000000; #1;
        if (y4 !== 1'b1) test_passed = 1'b0;
        
        // Final result
        if (test_passed) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        
        $finish;
    end

endmodule