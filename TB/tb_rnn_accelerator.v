`timescale 1ns/1ps

module rnn_accelerator_tb;
    parameter DATA_WIDTH = 16;
    parameter HIDDEN_SIZE = 64;
    parameter SEQUENCE_LENGTH = 32;

    logic clk;
    logic rst_n;
    logic [DATA_WIDTH-1:0] input_data[SEQUENCE_LENGTH-1:0];
    logic [DATA_WIDTH-1:0] output_data[SEQUENCE_LENGTH-1:0];

    rnn_accelerator #(
        .DATA_WIDTH(DATA_WIDTH),
        .HIDDEN_SIZE(HIDDEN_SIZE),
        .SEQUENCE_LENGTH(SEQUENCE_LENGTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .input_data(input_data),
        .output_data(output_data)
    );

    initial begin
        clk = 0;
        rst_n = 0;
        for (int i = 0; i < SEQUENCE_LENGTH; i++) begin
            input_data[i] = $random();
        end

        @(posedge clk);
        rst_n = 1;

        // Wait for the RNN to process the input sequence
        repeat (SEQUENCE_LENGTH) @(posedge clk);

        // Check the output
        for (int i = 0; i < SEQUENCE_LENGTH; i++) begin
            // Add your output verification logic here
            if (output_data[i] != expected_output[i]) begin
                $display("TEST FAILED");
                $finish;
            end
        end

        $display("TEST PASSED");
        $finish;
    end

    always #5 clk = ~clk;
endmodule