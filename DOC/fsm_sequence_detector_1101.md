# FSM Sequence Detector 1101: A Complete Verilog Implementation Guide

## Introduction

Sequence detection is a fundamental operation in digital systems, appearing in applications ranging from communication protocols to security systems. A **Finite State Machine (FSM) Sequence Detector** monitors a serial data stream and asserts an output signal when a specific bit pattern is recognized.

This article presents a complete, verified Verilog implementation of a sequence detector for the pattern "1101". The design uses a Mealy FSM architecture with overlapping detection support, meaning it can detect back-to-back occurrences of the pattern even when they share common bits.

Understanding sequence detectors is essential for engineers working on:
- UART and serial communication interfaces
- Protocol decoders (I2C, SPI, CAN)
- Pattern matching in data streams
- Synchronization word detection
- Security and access control systems

## Design Architecture

### State Diagram Overview

The FSM uses four states to track progress through the target pattern "1101":

```
S_IDLE (000) - No match in progress
S_1    (001) - Detected "1"
S_11   (010) - Detected "11"
S_110  (011) - Detected "110"
```

When the FSM reaches state `S_110` and receives a `din=1`, the complete pattern "1101" has been detected, and the output is asserted.

### Key Design Decisions

**Mealy vs. Moore Architecture**: This implementation uses a Mealy-style output that depends on both the current state and the input. However, the output is registered, which adds one clock cycle of latency but eliminates glitches and improves timing characteristics.

**Overlapping Detection**: The FSM supports overlapping pattern detection. When a pattern is found in state `S_110` with `din=1`, the next state transitions to `S_1` rather than `S_IDLE`. This allows detection of patterns like "11011101" where the ending "1" of the first pattern serves as the starting "1" of the next.

## Code Analysis

### Design Module

```verilog
// FSM Sequence Detector for pattern "1101"
// Mealy FSM with overlapping detection support
module seq_detector_1101 (
    input  wire clk,
    input  wire rst_n,      // Active-low reset
    input  wire din,        // Serial data input
    output reg  detected    // High when "1101" is detected
);

    // State encoding
    localparam [2:0] S_IDLE = 3'b000,  // Initial state / No match
                     S_1    = 3'b001,  // Detected "1"
                     S_11   = 3'b010,  // Detected "11"
                     S_110  = 3'b011;  // Detected "110"

    reg [2:0] current_state, next_state;
```

The module declares a 3-bit state register, though only four states are used. This encoding leaves room for expansion and ensures clean synthesis results.

### State Register

```verilog
    // State register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= S_IDLE;
        end else begin
            current_state <= next_state;
        end
    end
```

The state register uses an asynchronous active-low reset, which is standard practice in ASIC and FPGA designs for reliable initialization.

### Next State Logic

```verilog
    // Next state logic
    always @(*) begin
        case (current_state)
            S_IDLE: begin
                if (din)
                    next_state = S_1;
                else
                    next_state = S_IDLE;
            end
            
            S_1: begin
                if (din)
                    next_state = S_11;
                else
                    next_state = S_IDLE;
            end
            
            S_11: begin
                if (din)
                    next_state = S_11;   // Stay in S_11 for consecutive 1s
                else
                    next_state = S_110;
            end
            
            S_110: begin
                if (din)
                    next_state = S_1;    // Pattern detected, go to S_1 for overlap
                else
                    next_state = S_IDLE;
            end
            
            default: begin
                next_state = S_IDLE;
            end
        endcase
    end
```

The combinational next-state logic implements the state transition table. Note the critical transition in `S_11`: when `din=1`, the FSM stays in `S_11` rather than advancing. This handles sequences like "111110..." correctly, waiting for the "0" that indicates progress toward the pattern.

### Output Logic

```verilog
    // Output logic (Mealy - depends on current state and input)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            detected <= 1'b0;
        end else begin
            // Detect "1101" when in S_110 and din=1
            if (current_state == S_110 && din == 1'b1)
                detected <= 1'b1;
            else
                detected <= 1'b0;
        end
    end
```

The registered output ensures glitch-free operation. The `detected` signal pulses high for exactly one clock cycle when the pattern is found.

## State Transition Table

| Current State | din | Next State | detected |
|---------------|-----|------------|----------|
| S_IDLE        | 0   | S_IDLE     | 0        |
| S_IDLE        | 1   | S_1        | 0        |
| S_1           | 0   | S_IDLE     | 0        |
| S_1           | 1   | S_11       | 0        |
| S_11          | 0   | S_110      | 0        |
| S_11          | 1   | S_11       | 0        |
| S_110         | 0   | S_IDLE     | 0        |
| S_110         | 1   | S_1        | 1        |

## Verification

This design has been automatically verified using a comprehensive testbench that validates:

1. **Reset behavior**: Confirms the FSM initializes to `S_IDLE` with `detected=0`
2. **Pattern detection**: Tests a 17-bit sequence with four expected detections
3. **No false positives**: Verifies that all-zero input produces no spurious detections
4. **Post-reset operation**: Confirms correct detection immediately after reset
5. **Overlapping patterns**: Validates detection of "11101" where multiple "1"s precede "101"

### Test Sequence Analysis

The primary test uses the input sequence:
```
Position: 0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15 16
Input:    0  1  1  0  1  1  1  0  1  0  1  1  0  1  1  0  1
Detected: 0  0  0  0  1  0  0  0  1  0  0  0  0  1  0  0  1
```

The pattern "1101" is detected at positions 4, 8, 13, and 16, demonstrating both normal and overlapping detection.

## Usage Example

### Basic Instantiation

```verilog
wire pattern_found;

seq_detector_1101 detector_inst (
    .clk(system_clk),
    .rst_n(reset_n),
    .din(serial_data_in),
    .detected(pattern_found)
);
```

### Real-World Application: Preamble Detection

In a communication system, the sequence detector can identify frame preambles:

```verilog
module frame_receiver (
    input  wire clk,
    input  wire rst_n,
    input  wire rx_data,
    output reg  frame_start,
    output reg  [7:0] data_out
);

    wire preamble_detected;
    reg [2:0] bit_count;
    reg receiving;

    seq_detector_1101 preamble_det (
        .clk(clk),
        .rst_n(rst_n),
        .din(rx_data),
        .detected(preamble_detected)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            receiving <= 1'b0;
            frame_start <= 1'b0;
            bit_count <= 3'd0;
        end else begin
            frame_start <= preamble_detected;
            if (preamble_detected) begin
                receiving <= 1'b1;
                bit_count <= 3'd0;
            end else if (receiving) begin
                data_out <= {data_out[6:0], rx_data};
                bit_count <= bit_count + 1'b1;
                if (bit_count == 3'd7)
                    receiving <= 1'b0;
            end
        end
    end

endmodule
```

## Synthesis Considerations

The design synthesizes efficiently on both FPGA and ASIC targets:

- **Resource usage**: 3 flip-flops for state, 1 flip-flop for output
- **Critical path**: Single combinational level for next-state logic
- **Clock frequency**: Suitable for high-speed applications due to registered output

For timing-critical designs, consider adding pipeline registers on the input if `din` arrives from an external source with significant routing delay.

## Conclusion

This FSM sequence detector provides a robust, verified solution for detecting the pattern "1101" in serial data streams. The overlapping detection capability and registered output make it suitable for production use in communication interfaces, protocol decoders, and synchronization circuits.

The complete source code, including the comprehensive testbench, can be directly integrated into larger designs. The modular structure allows easy modification for detecting different patterns by adjusting the state transitions and output conditions.