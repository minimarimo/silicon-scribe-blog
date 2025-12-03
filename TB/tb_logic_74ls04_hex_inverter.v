// Testbench for 74LS04 Hex Inverter
module tb_ls04_hex_inverter;

    // Test signals
    reg  [5:0] A;
    wire [5:0] Y;
    
    // Test variables
    integer i;
    reg test_passed;

    // Instantiate the Device Under Test (DUT)
    ls04_hex_inverter dut (
        .A(A),
        .Y(Y)
    );

    // Test procedure
    initial begin
        test_passed = 1'b1;
        
        $display("Starting 74LS04 Hex Inverter Test");
        $display("Time\tA[5:0]\tY[5:0]\tExpected");
        $display("----\t------\t------\t--------");
        
        // Test all possible input combinations (2^6 = 64 combinations)
        for (i = 0; i < 64; i = i + 1) begin
            A = i[5:0];
            #10; // Wait for propagation delay
            
            // Check if output is correct (should be inverted input)
            if (Y !== ~A) begin
                $display("%4t\t%b\t%b\t%b - FAIL", $time, A, Y, ~A);
                test_passed = 1'b0;
            end else begin
                $display("%4t\t%b\t%b\t%b - PASS", $time, A, Y, ~A);
            end
        end
        
        // Additional specific test cases
        $display("\nTesting specific cases:");
        
        // Test all zeros
        A = 6'b000000;
        #10;
        if (Y !== 6'b111111) begin
            $display("All zeros test FAILED");
            test_passed = 1'b0;
        end
        
        // Test all ones
        A = 6'b111111;
        #10;
        if (Y !== 6'b000000) begin
            $display("All ones test FAILED");
            test_passed = 1'b0;
        end
        
        // Test alternating pattern
        A = 6'b101010;
        #10;
        if (Y !== 6'b010101) begin
            $display("Alternating pattern test FAILED");
            test_passed = 1'b0;
        end
        
        // Test individual inverters
        for (i = 0; i < 6; i = i + 1) begin
            A = 6'b000000;
            A[i] = 1'b1;
            #10;
            if (Y[i] !== 1'b0 || Y !== (~A)) begin
                $display("Individual inverter %0d test FAILED", i+1);
                test_passed = 1'b0;
            end
        end
        
        // Final result
        $display("\n===================");
        if (test_passed) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $display("===================");
        
        $finish;
    end

endmodule