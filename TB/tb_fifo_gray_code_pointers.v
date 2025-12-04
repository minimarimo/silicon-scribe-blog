`timescale 1ns/1ps

module fifo_gray_tb;
    parameter DATA_WIDTH = 8;
    parameter DEPTH      = 16;

    logic        clk;
    logic        rst_n;
    logic        push;
    logic        pop;
    logic [DATA_WIDTH-1:0] data_in;
    logic [DATA_WIDTH-1:0] data_out;
    logic        full;
    logic        empty;

    fifo_gray #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .push(push),
        .pop(pop),
        .data_in(data_in),
        .data_out(data_out),
        .full(full),
        .empty(empty)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Testbench logic
    initial begin
        rst_n = 0;
        push = 0;
        pop = 0;
        data_in = '0;

        // Reset
        @(posedge clk);
        rst_n = 1;

        // Fill the FIFO
        repeat (DEPTH) begin
            @(posedge clk);
            push = 1;
            data_in = $random;
        end
        push = 0;

        // Drain the FIFO
        repeat (DEPTH) begin
            @(posedge clk);
            pop = 1;
        end
        pop = 0;

        // Check if FIFO is empty
        @(posedge clk);
        if (empty) begin
            $display("TEST PASSED");
        end
        else begin
            $display("TEST FAILED");
        end

        $finish;
    end

endmodule