// 74LS08 Quad 2-input AND Gate
module ls08_quad_and (
    input  wire a1, b1,  // Gate 1 inputs
    input  wire a2, b2,  // Gate 2 inputs
    input  wire a3, b3,  // Gate 3 inputs
    input  wire a4, b4,  // Gate 4 inputs
    output wire y1,      // Gate 1 output
    output wire y2,      // Gate 2 output
    output wire y3,      // Gate 3 output
    output wire y4       // Gate 4 output
);

    // Four independent 2-input AND gates
    assign y1 = a1 & b1;
    assign y2 = a2 & b2;
    assign y3 = a3 & b3;
    assign y4 = a4 & b4;

endmodule