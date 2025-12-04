# Understanding the 5-bit Johnson Counter: A Complete Verilog Implementation Guide

## Introduction

The Johnson counter, also known as a twisted ring counter or switch-tail counter, represents one of the most elegant sequential circuit designs in digital electronics. Unlike a standard binary counter that cycles through 2^N states, a Johnson counter produces 2N unique states for an N-bit implementation. This characteristic makes it particularly valuable in applications requiring glitch-free decoded outputs and simplified state machine implementations.

In this article, we explore a verified 5-bit Johnson counter implementation in Verilog, examining both the synthesizable design module and its comprehensive testbench. This counter cycles through 10 unique states, providing a clean, predictable sequence that finds applications in digital signal processing, timing circuits, and control systems.

## How the Johnson Counter Works

The fundamental principle behind a Johnson counter is straightforward: data shifts through a chain of flip-flops, with the inverted output of the last flip-flop feeding back to the first. This feedback mechanism creates the characteristic "walking ones" followed by "walking zeros" pattern.

For a 5-bit implementation, the state sequence is:

```
00000 -> 00001 -> 00011 -> 00111 -> 01111 -> 11111 -> 11110 -> 11100 -> 11000 -> 10000 -> (repeat)
```

This sequence demonstrates the counter filling with ones from the LSB, then emptying with zeros from the same position.

## Code Analysis

### Design Module Breakdown

```verilog
module johnson_counter_5bit (
    input  wire       clk,
    input  wire       rst_n,    // Active-low asynchronous reset
    input  wire       enable,   // Enable signal
    output reg  [4:0] q         // 5-bit counter output
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q <= 5'b00000;
        end
        else if (enable) begin
            // Shift left and feed inverted MSB to LSB
            q <= {q[3:0], ~q[4]};
        end
    end

endmodule
```

The design module implements several key features:

**Asynchronous Reset Logic**: The active-low reset signal (`rst_n`) provides immediate initialization to the zero state. This asynchronous behavior ensures the counter reaches a known state regardless of clock conditions, which is critical for reliable system startup.

**Enable Control**: The enable input allows external control over counting operations. When deasserted, the counter maintains its current state, providing flexibility in system integration where counting may need to pause.

**Shift and Feedback Operation**: The core functionality resides in the concatenation statement `{q[3:0], ~q[4]}`. This operation simultaneously shifts the lower four bits left while inserting the inverted MSB into the LSB position. The synthesis tool will implement this as five flip-flops with appropriate routing.

### Testbench Architecture

The testbench employs a structured verification approach with multiple test phases:

**Expected Sequence Array**: A pre-defined array stores all 10 valid states, enabling automated comparison during simulation.

```verilog
reg [4:0] expected_sequence [0:9];
// Initialized with the complete Johnson sequence
```

**Systematic Test Coverage**: The testbench executes five distinct test scenarios:

1. Reset functionality verification
2. Enable signal behavior when deasserted
3. Complete sequence validation across two full cycles
4. Asynchronous reset during active operation
5. Proper resumption after reset release

**Error Tracking**: An error counter accumulates failures throughout testing, providing a clear pass/fail determination at completion.

**Timeout Watchdog**: A safety mechanism prevents infinite simulation loops, terminating execution after 10 microseconds if tests fail to complete normally.

## Verification Status

This Johnson counter implementation has been automatically verified through simulation. The testbench confirms correct operation across all test scenarios, including edge cases such as reset assertion during active counting and proper state transitions through multiple complete cycles. The simulation produces clear "TEST PASSED" or "TEST FAILED" output, enabling integration into automated verification flows.

## Real-World Applications

### Decoded Output Generation

Johnson counters excel in applications requiring decoded outputs because adjacent states differ by only one bit. This property eliminates glitches in combinational decode logic:

```verilog
// Glitch-free decode for state 3 (00111)
assign state_3 = q[2] & ~q[3];
```

### Ring Oscillator Control

In mixed-signal designs, Johnson counters provide clean phase-shifted clock signals for multi-phase systems.

### Example Instantiation

```verilog
johnson_counter_5bit phase_generator (
    .clk    (system_clk),
    .rst_n  (power_on_reset_n),
    .enable (phase_enable),
    .q      (phase_state)
);

// Decode individual phases
assign phase_0 = (phase_state == 5'b00000);
assign phase_1 = (phase_state == 5'b00001);
// Additional phase decodes as needed
```

## Conclusion

The 5-bit Johnson counter provides a reliable, synthesis-ready building block for digital systems requiring predictable state sequences with glitch-free decoding capability. The verified implementation presented here includes essential features such as asynchronous reset and enable control, making it suitable for direct integration into larger designs. The accompanying testbench demonstrates thorough verification practices applicable to any sequential logic development.