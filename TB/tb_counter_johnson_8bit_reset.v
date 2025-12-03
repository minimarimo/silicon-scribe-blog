module tb_johnson_counter_8bit;

reg clk;
reg reset;
wire [7:0] count;

// Expected Johnson counter sequence
reg [7:0] expected_sequence [0:15];

johnson_counter_8bit dut (
    .clk(clk),
    .reset(reset),
    .count(count)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Initialize expected sequence
initial begin
    expected_sequence[0]  = 8'b00000000;
    expected_sequence[1]  = 8'b10000000;
    expected_sequence[2]  = 8'b11000000;
    expected_sequence[3]  = 8'b11100000;
    expected_sequence[4]  = 8'b11110000;
    expected_sequence[5]  = 8'b11111000;
    expected_sequence[6]  = 8'b11111100;
    expected_sequence[7]  = 8'b11111110;
    expected_sequence[8]  = 8'b11111111;
    expected_sequence[9]  = 8'b01111111;
    expected_sequence[10] = 8'b00111111;
    expected_sequence[11] = 8'b00011111;
    expected_sequence[12] = 8'b00001111;
    expected_sequence[13] = 8'b00000111;
    expected_sequence[14] = 8'b00000011;
    expected_sequence[15] = 8'b00000001;
end

// Test procedure
initial begin
    integer i;
    reg test_passed;
    
    test_passed = 1;
    
    // Initialize and apply reset
    reset = 1;
    #15;
    
    // Check reset condition
    if (count !== 8'b00000000) begin
        test_passed = 0;
    end
    
    // Release reset
    reset = 0;
    
    // Test complete Johnson counter sequence for one full cycle
    for (i = 0; i < 16; i = i + 1) begin
        @(posedge clk);
        #1; // Small delay for signal propagation
        if (count !== expected_sequence[(i + 1) % 16]) begin
            test_passed = 0;
        end
    end
    
    // Test reset during operation
    reset = 1;
    #15;
    if (count !== 8'b00000000) begin
        test_passed = 0;
    end
    
    // Release reset and verify restart
    reset = 0;
    @(posedge clk);
    #1;
    if (count !== expected_sequence[1]) begin
        test_passed = 0;
    end
    
    // Final result
    if (test_passed) begin
        $display("TEST PASSED");
    end else begin
        $display("TEST FAILED");
    end
    
    $finish;
end

endmodule