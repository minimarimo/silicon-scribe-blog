`timescale 1ns/1ps

module dual_edge_dff_tb;

    reg D;
    reg CLK;
    wire Q;

    dual_edge_dff dut (
        .D(D),
        .CLK(CLK),
        .Q(Q)
    );

    initial begin
        $dumpfile("dual_edge_dff_tb.vcd");
        $dumpvars(0, dual_edge_dff_tb);

        // Test case 1: Positive edge
        D = 1'b0;
        CLK = 1'b0;
        #5 CLK = 1'b1;
        #5 if (Q !== 1'b0) begin
            $display("TEST FAILED");
        end else begin
            $display("TEST PASSED");
        end

        // Test case 2: Negative edge
        D = 1'b1;
        #5 CLK = 1'b0;
        #5 if (Q !== 1'b1) begin
            $display("TEST FAILED");
        end else begin
            $display("TEST PASSED");
        end

        $finish;
    end

endmodule