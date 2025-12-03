module tb_gray_counter_4bit;

    reg clk;
    reg reset;
    wire [3:0] gray_count;
    
    // Expected Gray code sequence
    reg [3:0] expected_gray [0:15];
    integer i;
    reg test_passed;
    
    // Instantiate the DUT
    gray_counter_4bit dut (
        .clk(clk),
        .reset(reset),
        .gray_count(gray_count)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Initialize expected Gray code sequence
    initial begin
        expected_gray[0]  = 4'b0000;  // 0
        expected_gray[1]  = 4'b0001;  // 1
        expected_gray[2]  = 4'b0011;  // 2
        expected_gray[3]  = 4'b0010;  // 3
        expected_gray[4]  = 4'b0110;  // 4
        expected_gray[5]  = 4'b0111;  // 5
        expected_gray[6]  = 4'b0101;  // 6
        expected_gray[7]  = 4'b0100;  // 7
        expected_gray[8]  = 4'b1100;  // 8
        expected_gray[9]  = 4'b1101;  // 9
        expected_gray[10] = 4'b1111;  // 10
        expected_gray[11] = 4'b1110;  // 11
        expected_gray[12] = 4'b1010;  // 12
        expected_gray[13] = 4'b1011;  // 13
        expected_gray[14] = 4'b1001;  // 14
        expected_gray[15] = 4'b1000;  // 15
    end
    
    // Test sequence
    initial begin
        test_passed = 1;
        
        // Reset the counter
        reset = 1;
        #10;
        reset = 0;
        
        // Wait for reset to take effect and check initial value
        #1;
        if (gray_count !== expected_gray[0]) begin
            $display("ERROR: After reset, expected %b, got %b", expected_gray[0], gray_count);
            test_passed = 0;
        end
        
        // Check all 16 Gray code values
        for (i = 1; i < 16; i = i + 1) begin
            @(posedge clk);
            #1; // Small delay for signal propagation
            
            if (gray_count !== expected_gray[i]) begin
                $display("ERROR: At count %d, expected %b, got %b", i, expected_gray[i], gray_count);
                test_passed = 0;
            end
        end
        
        // Test wrap-around to 0
        @(posedge clk);
        #1;
        if (gray_count !== expected_gray[0]) begin
            $display("ERROR: Wrap-around failed, expected %b, got %b", expected_gray[0], gray_count);
            test_passed = 0;
        end
        
        // Test reset functionality during operation
        reset = 1;
        #1;
        if (gray_count !== expected_gray[0]) begin
            $display("ERROR: Reset during operation failed, expected %b, got %b", expected_gray[0], gray_count);
            test_passed = 0;
        end
        reset = 0;
        
        // Final result
        if (test_passed) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        
        $finish;
    end

endmodule