module tb_mux_4to1;

reg [1:0] sel;
reg [3:0] data_in;
wire data_out;
reg test_passed;

mux_4to1 uut (
    .sel(sel),
    .data_in(data_in),
    .data_out(data_out)
);

initial begin
    test_passed = 1'b1;
    
    // Test case 1: sel = 00, should select data_in[0]
    data_in = 4'b1010;
    sel = 2'b00;
    #10;
    if (data_out !== data_in[0]) begin
        test_passed = 1'b0;
        $display("Test 1 failed: sel=00, expected=%b, got=%b", data_in[0], data_out);
    end
    
    // Test case 2: sel = 01, should select data_in[1]
    sel = 2'b01;
    #10;
    if (data_out !== data_in[1]) begin
        test_passed = 1'b0;
        $display("Test 2 failed: sel=01, expected=%b, got=%b", data_in[1], data_out);
    end
    
    // Test case 3: sel = 10, should select data_in[2]
    sel = 2'b10;
    #10;
    if (data_out !== data_in[2]) begin
        test_passed = 1'b0;
        $display("Test 3 failed: sel=10, expected=%b, got=%b", data_in[2], data_out);
    end
    
    // Test case 4: sel = 11, should select data_in[3]
    sel = 2'b11;
    #10;
    if (data_out !== data_in[3]) begin
        test_passed = 1'b0;
        $display("Test 4 failed: sel=11, expected=%b, got=%b", data_in[3], data_out);
    end
    
    // Test case 5: Different input pattern
    data_in = 4'b0110;
    sel = 2'b00;
    #10;
    if (data_out !== data_in[0]) begin
        test_passed = 1'b0;
        $display("Test 5 failed: sel=00, expected=%b, got=%b", data_in[0], data_out);
    end
    
    sel = 2'b01;
    #10;
    if (data_out !== data_in[1]) begin
        test_passed = 1'b0;
        $display("Test 6 failed: sel=01, expected=%b, got=%b", data_in[1], data_out);
    end
    
    sel = 2'b10;
    #10;
    if (data_out !== data_in[2]) begin
        test_passed = 1'b0;
        $display("Test 7 failed: sel=10, expected=%b, got=%b", data_in[2], data_out);
    end
    
    sel = 2'b11;
    #10;
    if (data_out !== data_in[3]) begin
        test_passed = 1'b0;
        $display("Test 8 failed: sel=11, expected=%b, got=%b", data_in[3], data_out);
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