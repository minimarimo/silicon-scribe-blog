`timescale 1ns/1ps

module pipelined_relu_tb;

    logic        clk;
    logic        rst_n;
    logic [15:0] data_in;
    logic [15:0] data_out;

    pipelined_relu DUT (
        .clk     (clk),
        .rst_n   (rst_n),
        .data_in (data_in),
        .data_out(data_out)
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        @(posedge clk);
        rst_n = 1;

        // Positive value
        data_in = 16'h0010;
        @(posedge clk);
        if (data_out == 16'h0010) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED: Positive value");
        end

        // Negative value
        data_in = 16'hFFF0;
        @(posedge clk);
        if (data_out == 16'h0000) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED: Negative value");
        end

        #20 $finish;
    end

endmodule