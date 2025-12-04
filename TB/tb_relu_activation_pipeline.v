// Testbench
module pipelined_relu_tb #(
    parameter DATA_WIDTH = 16
);

    logic                 clk;
    logic                 rst_n;
    logic [DATA_WIDTH-1:0] din;
    logic [DATA_WIDTH-1:0] dout;

    pipelined_relu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .din(din),
        .dout(dout)
    );

    initial begin
        clk = 0;
        rst_n = 0;
        din = '0;
        #100 rst_n = 1;
    end

    always #10 clk = ~clk;

    initial begin
        // Positive values
        din = 16'h0005;
        #20;
        assert (dout == 16'h0005) else $error("TEST FAILED: Positive value");

        // Negative values
        din = 16'hFFF5;
        #20;
        assert (dout == 16'h0000) else $error("TEST FAILED: Negative value");

        // Zero value
        din = 16'h0000;
        #20;
        assert (dout == 16'h0000) else $error("TEST FAILED: Zero value");

        $display("TEST PASSED");
        $finish;
    end

endmodule