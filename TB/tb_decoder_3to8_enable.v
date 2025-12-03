module tb_decoder_3to8;

reg [2:0] select;
reg enable;
wire [7:0] out;

decoder_3to8 dut (
    .select(select),
    .enable(enable),
    .out(out)
);

reg test_passed;
integer i;

initial begin
    test_passed = 1'b1;
    
    // Test with enable = 0 (disabled)
    enable = 1'b0;
    for (i = 0; i < 8; i = i + 1) begin
        select = i[2:0];
        #10;
        if (out !== 8'b00000000) begin
            $display("FAIL: Enable=0, Select=%b, Expected=00000000, Got=%b", select, out);
            test_passed = 1'b0;
        end
    end
    
    // Test with enable = 1 (enabled)
    enable = 1'b1;
    
    // Test select = 000
    select = 3'b000;
    #10;
    if (out !== 8'b00000001) begin
        $display("FAIL: Select=000, Expected=00000001, Got=%b", out);
        test_passed = 1'b0;
    end
    
    // Test select = 001
    select = 3'b001;
    #10;
    if (out !== 8'b00000010) begin
        $display("FAIL: Select=001, Expected=00000010, Got=%b", out);
        test_passed = 1'b0;
    end
    
    // Test select = 010
    select = 3'b010;
    #10;
    if (out !== 8'b00000100) begin
        $display("FAIL: Select=010, Expected=00000100, Got=%b", out);
        test_passed = 1'b0;
    end
    
    // Test select = 011
    select = 3'b011;
    #10;
    if (out !== 8'b00001000) begin
        $display("FAIL: Select=011, Expected=00001000, Got=%b", out);
        test_passed = 1'b0;
    end
    
    // Test select = 100
    select = 3'b100;
    #10;
    if (out !== 8'b00010000) begin
        $display("FAIL: Select=100, Expected=00010000, Got=%b", out);
        test_passed = 1'b0;
    end
    
    // Test select = 101
    select = 3'b101;
    #10;
    if (out !== 8'b00100000) begin
        $display("FAIL: Select=101, Expected=00100000, Got=%b", out);
        test_passed = 1'b0;
    end
    
    // Test select = 110
    select = 3'b110;
    #10;
    if (out !== 8'b01000000) begin
        $display("FAIL: Select=110, Expected=01000000, Got=%b", out);
        test_passed = 1'b0;
    end
    
    // Test select = 111
    select = 3'b111;
    #10;
    if (out !== 8'b10000000) begin
        $display("FAIL: Select=111, Expected=10000000, Got=%b", out);
        test_passed = 1'b0;
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