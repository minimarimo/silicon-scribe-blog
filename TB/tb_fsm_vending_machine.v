`timescale 1ns / 1ps

module vending_machine_controller_tb;

    // Inputs
    reg clk;
    reg reset;
    reg coin_inserted;
    reg product_selected;

    // Outputs
    wire vend_product;
    wire change_returned;

    // Instantiate the Design Under Test (DUT)
    vending_machine_controller dut (
        .clk(clk),
        .reset(reset),
        .coin_inserted(coin_inserted),
        .product_selected(product_selected),
        .vend_product(vend_product),
        .change_returned(change_returned)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Testbench
    initial begin
        // Initialize inputs
        clk = 0;
        reset = 1;
        coin_inserted = 0;
        product_selected = 0;

        // Reset the DUT
        @(posedge clk);
        reset = 0;

        // Test case 1: Insert a coin, select a product, and verify the vending
        @(posedge clk);
        coin_inserted = 1;
        @(posedge clk);
        coin_inserted = 0;
        @(posedge clk);
        product_selected = 1;
        @(posedge clk);
        @(posedge clk);
        if (vend_product && !change_returned) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end

        // Test case 2: Insert a coin, do not select a product, and verify the change is returned
        @(posedge clk);
        coin_inserted = 1;
        @(posedge clk);
        coin_inserted = 0;
        @(posedge clk);
        if (!vend_product && change_returned) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end

        $finish;
    end

endmodule