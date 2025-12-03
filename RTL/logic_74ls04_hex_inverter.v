// 74LS04 Hex Inverter Module
module ls04_hex_inverter (
    input  wire [5:0] A,    // 6 input pins (A1-A6)
    output wire [5:0] Y     // 6 output pins (Y1-Y6)
);

    // Each output is the inverse of its corresponding input
    assign Y[0] = ~A[0];    // Y1 = ~A1
    assign Y[1] = ~A[1];    // Y2 = ~A2
    assign Y[2] = ~A[2];    // Y3 = ~A3
    assign Y[3] = ~A[3];    // Y4 = ~A4
    assign Y[4] = ~A[4];    // Y5 = ~A5
    assign Y[5] = ~A[5];    // Y6 = ~A6

endmodule