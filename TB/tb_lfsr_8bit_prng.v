`timescale 1ns/1ps

module lfsr_8bit_tb;

    reg clk;
    reg rst;
    wire [7:0] q;

    lfsr_8bit dut (
        .clk(clk),
        .rst(rst),
        .q(q)
    );

    initial begin
        clk = 0;
        rst = 1;
        #10 rst = 0;

        repeat (256) begin
            #10 clk = ~clk;
            check_output();
        end

        $display("TEST PASSED");
        $finish;
    end

    task check_output();
        reg [7:0] expected;
        case (q)
            8'b10000000: expected = 8'b01000000;
            8'b01000000: expected = 8'b00100000;
            8'b00100000: expected = 8'b00010000;
            8'b00010000: expected = 8'b00001000;
            8'b00001000: expected = 8'b00000100;
            8'b00000100: expected = 8'b00000010;
            8'b00000010: expected = 8'b00000001;
            8'b00000001: expected = 8'b10000011;
            default: expected = 8'hxx;
        endcase

        if (q !== expected) begin
            $display("TEST FAILED: expected %b, got %b", expected, q);
            $finish;
        end
    endtask

endmodule