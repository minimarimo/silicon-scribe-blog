// Testbench for 74LS00 Quad 2-input NAND Gate
module tb_ls00_quad_nand;

    // Test signals
    reg a1, b1, a2, b2, a3, b3, a4, b4;
    wire y1, y2, y3, y4;
    
    // Expected outputs
    reg expected_y1, expected_y2, expected_y3, expected_y4;
    
    // Test result flag
    reg test_passed;
    
    // Instantiate the DUT
    ls00_quad_nand dut (
        .a1(a1), .b1(b1), .y1(y1),
        .a2(a2), .b2(b2), .y2(y2),
        .a3(a3), .b3(b3), .y3(y3),
        .a4(a4), .b4(b4), .y4(y4)
    );
    
    // Test procedure
    initial begin
        test_passed = 1'b1;
        
        // Test all combinations for each gate
        // Gate 1: Test all 4 input combinations
        {a1, b1} = 2'b00; expected_y1 = 1'b1; #10;
        if (y1 !== expected_y1) test_passed = 1'b0;
        
        {a1, b1} = 2'b01; expected_y1 = 1'b1; #10;
        if (y1 !== expected_y1) test_passed = 1'b0;
        
        {a1, b1} = 2'b10; expected_y1 = 1'b1; #10;
        if (y1 !== expected_y1) test_passed = 1'b0;
        
        {a1, b1} = 2'b11; expected_y1 = 1'b0; #10;
        if (y1 !== expected_y1) test_passed = 1'b0;
        
        // Gate 2: Test all 4 input combinations
        {a2, b2} = 2'b00; expected_y2 = 1'b1; #10;
        if (y2 !== expected_y2) test_passed = 1'b0;
        
        {a2, b2} = 2'b01; expected_y2 = 1'b1; #10;
        if (y2 !== expected_y2) test_passed = 1'b0;
        
        {a2, b2} = 2'b10; expected_y2 = 1'b1; #10;
        if (y2 !== expected_y2) test_passed = 1'b0;
        
        {a2, b2} = 2'b11; expected_y2 = 1'b0; #10;
        if (y2 !== expected_y2) test_passed = 1'b0;
        
        // Gate 3: Test all 4 input combinations
        {a3, b3} = 2'b00; expected_y3 = 1'b1; #10;
        if (y3 !== expected_y3) test_passed = 1'b0;
        
        {a3, b3} = 2'b01; expected_y3 = 1'b1; #10;
        if (y3 !== expected_y3) test_passed = 1'b0;
        
        {a3, b3} = 2'b10; expected_y3 = 1'b1; #10;
        if (y3 !== expected_y3) test_passed = 1'b0;
        
        {a3, b3} = 2'b11; expected_y3 = 1'b0; #10;
        if (y3 !== expected_y3) test_passed = 1'b0;
        
        // Gate 4: Test all 4 input combinations
        {a4, b4} = 2'b00; expected_y4 = 1'b1; #10;
        if (y4 !== expected_y4) test_passed = 1'b0;
        
        {a4, b4} = 2'b01; expected_y4 = 1'b1; #10;
        if (y4 !== expected_y4) test_passed = 1'b0;
        
        {a4, b4} = 2'b10; expected_y4 = 1'b1; #10;
        if (y4 !== expected_y4) test_passed = 1'b0;
        
        {a4, b4} = 2'b11; expected_y4 = 1'b0; #10;
        if (y4 !== expected_y4) test_passed = 1'b0;
        
        // Test all gates simultaneously with different inputs
        {a1, b1, a2, b2, a3, b3, a4, b4} = 8'b11001101;
        expected_y1 = 1'b0; expected_y2 = 1'b1; 
        expected_y3 = 1'b0; expected_y4 = 1'b1;
        #10;
        if (y1 !== expected_y1 || y2 !== expected_y2 || 
            y3 !== expected_y3 || y4 !== expected_y4) 
            test_passed = 1'b0;
        
        // Final test result
        if (test_passed)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
            
        $finish;
    end

endmodule