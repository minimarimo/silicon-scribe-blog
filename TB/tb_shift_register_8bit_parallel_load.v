`timescale 1ns / 1ps

module shift_register_8bit_tb;

    reg clk;
    reg reset;
    reg load;
    reg [7:0] data_in;
    wire [7:0] data_out;

    shift_register_8bit DUT (
        .clk(clk),
        .reset(reset),
        .load(load),
        .data_in(data_in),
        .data_out(data_out)
    );

    initial begin
        clk = 0;
        reset = 1;
        load = 0;
        data_in = 8'b10101010;
        #10 reset = 0;
        #10 load = 1;
        #10 load = 0;
        #80 $finish;
    end

    always #5 clk = ~clk;

    initial begin
        // Test Parallel Load
        @(posedge clk);
        assert(data_out == 8'b10101010) $display("TEST PASSED");
        else $display("TEST FAILED");

        // Test Shift Operation
        repeat(8) @(posedge clk);
        assert(data_out == 8'b01010101) $display("TEST PASSED");
        else $display("TEST FAILED");
    end

endmodule