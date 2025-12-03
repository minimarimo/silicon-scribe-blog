// Testbench for 74LS08 Quad 2-input AND Gate
module tb_ls08_quad_and;

    // Test signals
    reg a1, b1, a2, b2, a3, b3, a4, b4;
    wire y1, y2, y3, y4;
    
    // Test vectors counter
    reg [7:0] test_count;
    reg test_passed;

    // Instantiate the device under test
    ls08_quad_and dut (
        .a1(a1), .b1(b1), .y1(y1),
        .a2(a2), .b2(b2), .y2(y2),
        .a3(a3), .b3(b3), .y3(y3),
        .a4(a4), .b4(b4), .y4(y4)
    );

    initial begin
        test_passed = 1'b1;
        test_count = 0;
        
        // Test all combinations for each gate
        // Gate 1 tests
        {a1, b1} = 2'b00; #10;
        if (y1 !== 1'b0) test_passed = 1'b0;
        test_count = test_count + 1;
        
        {a1, b1} = 2'b01; #10;
        if (y1 !== 1'b0) test_passed = 1'b0;
        test_count = test_count + 1;
        
        {a1, b1} = 2'b10; #10;
        if (y1 !== 1'b0) test_passed = 1'b0;
        test_count = test_count + 1;
        
        {a1, b1} = 2'b11; #10;
        if (y1 !== 1'b1) test_passed = 1'b0;
        test_count = test_count + 1;
        
        // Gate 2 tests
        {a2, b2} = 2'b00; #10;
        if (y2 !== 1'b0) test_passed = 1'b0;
        test_count = test_count + 1;
        
        {a2, b2} = 2'b01; #10;
        if (y2 !== 1'b0) test_passed = 1'b0;
        test_count = test_count + 1;
        
        {a2, b2} = 2'b10; #10;
        if (y2 !== 1'b0) test_passed = 1'b0;
        test_count = test_count + 1;
        
        {a2, b2} = 2'b11; #10;
        if (y2 !== 1'b1) test_passed = 1'b0;
        test_count = test_count + 1;
        
        // Gate 3 tests
        {a3, b3} = 2'b00; #10;
        if (y3 !== 1'b0) test_passed = 1'b0;
        test_count = test_count + 1;
        
        {a3, b3} = 2'b01; #10;
        if (y3 !== 1'b0) test_passed = 1'b0;
        test_count = test_count + 1;
        
        {a3, b3} = 2'b10; #10;
        if (y3 !== 1'b0) test_passed = 1'b0;
        test_count = test_count + 1;
        
        {a3, b3} = 2'b11; #10;
        if (y3 !== 1'b1) test_passed = 1'b0;
        test_count = test_count + 1;
        
        // Gate 4 tests
        {a4, b4} = 2'b00; #10;
        if (y4 !== 1'b0) test_passed = 1'b0;
        test_count = test_count + 1;
        
        {a4, b4} = 2'b01; #10;
        if (y4 !== 1'b0) test_passed = 1'b0;
        test_count = test_count + 1;
        
        {a4, b4} = 2'b10; #10;
        if (y4 !== 1'b0) test_passed = 1'b0;
        test_count = test_count + 1;
        
        {a4, b4} = 2'b11; #10;
        if (y4 !== 1'b1) test_passed = 1'b0;
        test_count = test_count + 1;
        
        // Test all gates simultaneously
        {a1, b1, a2, b2, a3, b3, a4, b4} = 8'b11111111; #10;
        if (y1 !== 1'b1 || y2 !== 1'b1 || y3 !== 1'b1 || y4 !== 1'b1) 
            test_passed = 1'b0;
        test_count = test_count + 1;
        
        {a1, b1, a2, b2, a3, b3, a4, b4} = 8'b00000000; #10;
        if (y1 !== 1'b0 || y2 !== 1'b0 || y3 !== 1'b0 || y4 !== 1'b0) 
            test_passed = 1'b0;
        test_count = test_count + 1;
        
        // Display results
        if (test_passed) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        
        $finish;
    end

endmodule