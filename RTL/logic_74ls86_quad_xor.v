// 74LS86 Quad 2-input XOR Gate
module ls86_quad_xor (
    input  wire A1, B1,  // Gate 1 inputs
    input  wire A2, B2,  // Gate 2 inputs
    input  wire A3, B3,  // Gate 3 inputs
    input  wire A4, B4,  // Gate 4 inputs
    output wire Y1,      // Gate 1 output
    output wire Y2,      // Gate 2 output
    output wire Y3,      // Gate 3 output
    output wire Y4       // Gate 4 output
);

    // Four independent 2-input XOR gates
    assign Y1 = A1 ^ B1;
    assign Y2 = A2 ^ B2;
    assign Y3 = A3 ^ B3;
    assign Y4 = A4 ^ B4;

endmodule