`timescale 1ns / 1ps

module tb_counter;

    // Signal Declarations
    reg        clk;
    reg        rst_n;
    wire [3:0] out;

    // Instantiate the Device Under Test (DUT)
    counter u_counter (
        .clk   (clk),
        .rst_n (rst_n),
        .out   (out)
    );

    // Clock Generation (10ns period)
    always #5 clk = ~clk;

    // Test Procedure
    initial begin
        // Initialize
        clk = 0;
        rst_n = 0;

        // Dump waves (Optional, for debugging with GTKWave)
        $dumpfile("counter_waves.vcd");
        $dumpvars(0, tb_counter);

        // 1. Hold Reset
        #20;
        rst_n = 1; // Release Reset

        // 2. Wait for 5 clock cycles
        // Expected sequence: 0 -> 1 -> 2 -> 3 -> 4 -> 5
        repeat (5) @(posedge clk);

        // 3. Verification Logic (Self-Checking)
        #1; // Wait a tiny bit after clock edge to sample stable output

        if (out === 4'b0101) begin // Expecting 5
            $display("------------------------------------------------");
            $display("[TB] Checkpoint: Counter value is %d", out);
            $display("TEST PASSED"); // <--- KEYWORD for judge_core.sh
            $display("------------------------------------------------");
        end else begin
            $display("------------------------------------------------");
            $display("[TB] Error: Expected 5, got %d", out);
            $display("TEST FAILED");
            $display("------------------------------------------------");
        end

        // End Simulation
        $finish;
    end

endmodule
