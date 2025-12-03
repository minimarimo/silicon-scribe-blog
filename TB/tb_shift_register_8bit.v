module tb_shift_register_8bit;
    reg clk;
    reg rst_n;
    reg shift_en;
    reg serial_in;
    wire [7:0] parallel_out;
    wire serial_out;
    
    // Test variables
    reg [7:0] expected_data;
    reg test_passed;
    integer i;
    
    // Instantiate the shift register
    shift_register_8bit uut (
        .clk(clk),
        .rst_n(rst_n),
        .shift_en(shift_en),
        .serial_in(serial_in),
        .parallel_out(parallel_out),
        .serial_out(serial_out)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test sequence
    initial begin
        test_passed = 1;
        
        // Initialize signals
        rst_n = 1;
        shift_en = 0;
        serial_in = 0;
        
        // Test 1: Asynchronous reset
        #10;
        rst_n = 0;
        #10;
        if (parallel_out !== 8'b0) begin
            $display("TEST FAILED: Reset test - Expected: 8'b0, Got: %b", parallel_out);
            test_passed = 0;
        end
        
        // Release reset
        rst_n = 1;
        #10;
        
        // Test 2: Shift disabled (should not shift)
        shift_en = 0;
        serial_in = 1;
        #20;
        if (parallel_out !== 8'b0) begin
            $display("TEST FAILED: Shift disabled test - Expected: 8'b0, Got: %b", parallel_out);
            test_passed = 0;
        end
        
        // Test 3: Shift in pattern 10101010
        shift_en = 1;
        expected_data = 8'b0;
        
        // Shift in 1,0,1,0,1,0,1,0
        for (i = 0; i < 8; i = i + 1) begin
            serial_in = i % 2; // alternating 0,1,0,1,0,1,0,1
            expected_data = {expected_data[6:0], serial_in};
            #10;
            if (parallel_out !== expected_data) begin
                $display("TEST FAILED: Shift test step %d - Expected: %b, Got: %b", i+1, expected_data, parallel_out);
                test_passed = 0;
            end
        end
        
        // Test 4: Check serial output
        if (serial_out !== parallel_out[7]) begin
            $display("TEST FAILED: Serial output test - Expected: %b, Got: %b", parallel_out[7], serial_out);
            test_passed = 0;
        end
        
        // Test 5: Shift in all 1s
        for (i = 0; i < 8; i = i + 1) begin
            serial_in = 1;
            expected_data = {expected_data[6:0], 1'b1};
            #10;
            if (parallel_out !== expected_data) begin
                $display("TEST FAILED: All 1s shift test step %d - Expected: %b, Got: %b", i+1, expected_data, parallel_out);
                test_passed = 0;
            end
        end
        
        // Test 6: Test reset during operation
        serial_in = 0;
        #5;
        rst_n = 0;
        #5;
        if (parallel_out !== 8'b0) begin
            $display("TEST FAILED: Reset during operation - Expected: 8'b0, Got: %b", parallel_out);
            test_passed = 0;
        end
        
        // Final result
        if (test_passed) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        
        #20;
        $finish;
    end
    
endmodule