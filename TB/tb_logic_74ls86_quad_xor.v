// Testbench for 74LS86 Quad 2-input XOR Gate
module tb_ls86_quad_xor;

    // Test signals
    reg A1, B1, A2, B2, A3, B3, A4, B4;
    wire Y1, Y2, Y3, Y4;
    
    // Expected outputs
    reg expected_Y1, expected_Y2, expected_Y3, expected_Y4;
    
    // Test result tracking
    integer test_count;
    integer pass_count;
    
    // Instantiate the DUT
    ls86_quad_xor dut (
        .A1(A1), .B1(B1), .Y1(Y1),
        .A2(A2), .B2(B2), .Y2(Y2),
        .A3(A3), .B3(B3), .Y3(Y3),
        .A4(A4), .B4(B4), .Y4(Y4)
    );
    
    // Test task
    task check_outputs;
        begin
            test_count = test_count + 1;
            expected_Y1 = A1 ^ B1;
            expected_Y2 = A2 ^ B2;
            expected_Y3 = A3 ^ B3;
            expected_Y4 = A4 ^ B4;
            
            #1; // Small delay for signal propagation
            
            if (Y1 === expected_Y1 && Y2 === expected_Y2 && 
                Y3 === expected_Y3 && Y4 === expected_Y4) begin
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: A1=%b B1=%b A2=%b B2=%b A3=%b B3=%b A4=%b B4=%b", 
                        A1, B1, A2, B2, A3, B3, A4, B4);
                $display("      Expected: Y1=%b Y2=%b Y3=%b Y4=%b", 
                        expected_Y1, expected_Y2, expected_Y3, expected_Y4);
                $display("      Got:      Y1=%b Y2=%b Y3=%b Y4=%b", 
                        Y1, Y2, Y3, Y4);
            end
        end
    endtask
    
    initial begin
        // Initialize counters
        test_count = 0;
        pass_count = 0;
        
        // Test all combinations for each gate
        // This tests all 16 combinations of inputs for each gate
        
        // Test Gate 1 exhaustively while others are at known states
        A2 = 0; B2 = 0; A3 = 0; B3 = 0; A4 = 0; B4 = 0;
        for (integer i = 0; i < 4; i = i + 1) begin
            {A1, B1} = i;
            check_outputs();
        end
        
        // Test Gate 2 exhaustively while others are at known states
        A1 = 0; B1 = 0; A3 = 0; B3 = 0; A4 = 0; B4 = 0;
        for (integer i = 0; i < 4; i = i + 1) begin
            {A2, B2} = i;
            check_outputs();
        end
        
        // Test Gate 3 exhaustively while others are at known states
        A1 = 0; B1 = 0; A2 = 0; B2 = 0; A4 = 0; B4 = 0;
        for (integer i = 0; i < 4; i = i + 1) begin
            {A3, B3} = i;
            check_outputs();
        end
        
        // Test Gate 4 exhaustively while others are at known states
        A1 = 0; B1 = 0; A2 = 0; B2 = 0; A3 = 0; B3 = 0;
        for (integer i = 0; i < 4; i = i + 1) begin
            {A4, B4} = i;
            check_outputs();
        end
        
        // Test some random combinations of all gates
        {A1, B1, A2, B2, A3, B3, A4, B4} = 8'b10110011;
        check_outputs();
        
        {A1, B1, A2, B2, A3, B3, A4, B4} = 8'b01011010;
        check_outputs();
        
        {A1, B1, A2, B2, A3, B3, A4, B4} = 8'b11110000;
        check_outputs();
        
        {A1, B1, A2, B2, A3, B3, A4, B4} = 8'b00001111;
        check_outputs();
        
        {A1, B1, A2, B2, A3, B3, A4, B4} = 8'b10101010;
        check_outputs();
        
        {A1, B1, A2, B2, A3, B3, A4, B4} = 8'b01010101;
        check_outputs();
        
        // Final result
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
            $display("Passed %0d out of %0d tests", pass_count, test_count);
        end
        
        $finish;
    end

endmodule