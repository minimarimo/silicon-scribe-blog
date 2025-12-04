module dual_edge_dff (
    input  wire D,
    input  wire CLK,
    output reg  Q
);

    always @(posedge CLK, negedge CLK) begin
        Q <= D;
    end

endmodule