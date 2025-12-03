# Implementing a Moore FSM for 1011 Sequence Detection in Verilog

## Introduction

Sequence detection is a fundamental requirement in digital communication systems, protocol analyzers, and data processing applications. A sequence detector is a finite state machine (FSM) that monitors an incoming serial data stream and generates an output signal when a specific bit pattern is detected. This article presents a robust Moore FSM implementation for detecting the binary sequence "1011" with support for overlapping pattern detection.

The Moore FSM architecture is particularly well-suited for sequence detection because its outputs depend solely on the current state, providing stable and predictable behavior that is essential for reliable pattern recognition in digital systems.

## Code Analysis

### State Machine Architecture

The sequence detector implements a 5-state Moore FSM with the following state encoding:

```verilog
parameter IDLE = 3'b000;  // Initial state
parameter S1   = 3'b001;  // Detected first '1'
parameter S10  = 3'b010;  // Detected '10'
parameter S101 = 3'b011;  // Detected '101'
parameter S1011= 3'b100;  // Detected complete '1011'
```

### State Transition Logic

The FSM's next-state logic handles all possible input combinations while maintaining the ability to detect overlapping sequences:

- **IDLE State**: Waits for the first '1' bit to begin sequence detection
- **S1 State**: Remains in S1 for consecutive '1' bits, transitions to S10 on '0'
- **S10 State**: Transitions to S101 on '1', returns to IDLE on '0'
- **S101 State**: Critical state that transitions to S1011 on '1' or S10 on '0' (enabling overlapping detection)
- **S1011 State**: Detection complete, transitions appropriately for continued monitoring

### Key Design Features

The most crucial aspect of this implementation is the transition from S101 state on receiving a '0':

```verilog
S101: begin
    if (data_in)
        next_state = S1011;
    else
        next_state = S10;  // Enables overlapping sequence detection
end
```

This transition to S10 (rather than IDLE) allows the FSM to detect overlapping sequences such as "10110111" where multiple "1011" patterns exist.

### Output Logic

As a Moore FSM, the output depends only on the current state:

```verilog
always @(*) begin
    case (current_state)
        S1011: detected = 1'b1;
        default: detected = 1'b0;
    endcase
end
```

## Verification

This implementation has been thoroughly verified using a comprehensive testbench that validates:

1. **Basic sequence detection**: Verifies detection of standalone "1011" pattern
2. **Overlapping sequences**: Tests detection in patterns like "101101011"
3. **False positive prevention**: Ensures no detection for invalid sequences
4. **Edge cases**: Handles multiple consecutive '1' bits followed by valid patterns
5. **Reset functionality**: Confirms proper initialization and state recovery

The testbench employs bit-by-bit input simulation with explicit timing control, ensuring reliable verification across all test scenarios.

## Real-World Applications

### Communication Protocols

This sequence detector can be integrated into UART receivers, SPI controllers, or custom communication protocols where specific bit patterns indicate frame boundaries, command codes, or synchronization markers.

### Example Instantiation

```verilog
module uart_frame_detector (
    input wire clk,
    input wire reset,
    input wire rx_data,
    output wire frame_start
);

    sequence_detector_1011 detector (
        .clk(clk),
        .reset(reset),
        .data_in(rx_data),
        .detected(frame_start)
    );

endmodule
```

### Network Processing

In network packet processing, sequence detectors identify protocol headers, payload boundaries, or error detection patterns within high-speed data streams.

### Test Equipment

Protocol analyzers and logic analyzers utilize sequence detection for trigger generation, allowing engineers to capture specific events in complex digital systems.

## Performance Characteristics

- **Clock-to-output delay**: Single clock cycle (Moore FSM characteristic)
- **Resource utilization**: Minimal - requires only 3 flip-flops for state storage
- **Maximum frequency**: Limited primarily by combinational logic delays in state transitions
- **Power consumption**: Low due to simple logic structure

## Conclusion

This Moore FSM sequence detector provides a robust, verified solution for detecting the "1011" bit pattern in serial data streams. Its support for overlapping sequence detection and stable output characteristics make it suitable for a wide range of digital communication and data processing applications. The clean separation of state logic and output generation ensures maintainable code that can be easily modified for different sequence patterns or extended functionality.