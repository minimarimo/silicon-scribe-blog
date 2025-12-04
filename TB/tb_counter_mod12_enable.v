`timescale 1ns/1ps

module mod12_counter_tb;

reg clk;
reg reset;
reg enable;
wire [3:0] count;

mod12_counter DUT (
    .clk(clk),
    .reset(reset),
    .enable(enable),
    .count(count)
);

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

initial begin
    reset = 1'b1;
    enable = 1'b0;
    #10 reset = 1'b0;
    enable = 1'b1;

    #140 // Run for 140 clock cycles
    if (count == 4'b0000) begin
        $display("TEST PASSED");
    end
    else begin
        $display("TEST FAILED");
    end

    $finish;
end

endmodule