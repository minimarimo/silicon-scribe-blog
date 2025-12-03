module tb_adder_8bit;

    reg [7:0] a, b;
    reg cin;
    wire [7:0] sum;
    wire cout;
    
    reg [8:0] expected_result;
    integer test_count;
    integer pass_count;

    adder_8bit uut (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    initial begin
        test_count = 0;
        pass_count = 0;
        
        // Test case 1: Simple addition without carry
        a = 8'h0F; b = 8'h10; cin = 1'b0;
        expected_result = 9'h01F;
        #10;
        test_count = test_count + 1;
        if ({cout, sum} == expected_result)
            pass_count = pass_count + 1;
        
        // Test case 2: Addition with carry in
        a = 8'h0F; b = 8'h10; cin = 1'b1;
        expected_result = 9'h020;
        #10;
        test_count = test_count + 1;
        if ({cout, sum} == expected_result)
            pass_count = pass_count + 1;
        
        // Test case 3: Maximum values with carry out
        a = 8'hFF; b = 8'hFF; cin = 1'b0;
        expected_result = 9'h1FE;
        #10;
        test_count = test_count + 1;
        if ({cout, sum} == expected_result)
            pass_count = pass_count + 1;
        
        // Test case 4: Maximum values with carry in and carry out
        a = 8'hFF; b = 8'hFF; cin = 1'b1;
        expected_result = 9'h1FF;
        #10;
        test_count = test_count + 1;
        if ({cout, sum} == expected_result)
            pass_count = pass_count + 1;
        
        // Test case 5: Zero addition
        a = 8'h00; b = 8'h00; cin = 1'b0;
        expected_result = 9'h000;
        #10;
        test_count = test_count + 1;
        if ({cout, sum} == expected_result)
            pass_count = pass_count + 1;
        
        // Test case 6: One operand zero
        a = 8'h00; b = 8'hAA; cin = 1'b0;
        expected_result = 9'h0AA;
        #10;
        test_count = test_count + 1;
        if ({cout, sum} == expected_result)
            pass_count = pass_count + 1;
        
        // Test case 7: Carry propagation
        a = 8'h80; b = 8'h80; cin = 1'b0;
        expected_result = 9'h100;
        #10;
        test_count = test_count + 1;
        if ({cout, sum} == expected_result)
            pass_count = pass_count + 1;
        
        // Test case 8: Random test
        a = 8'h55; b = 8'h33; cin = 1'b1;
        expected_result = 9'h089;
        #10;
        test_count = test_count + 1;
        if ({cout, sum} == expected_result)
            pass_count = pass_count + 1;
        
        // Check results
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        
        $finish;
    end

endmodule