# Pipelined ReLU Activation Unit

## Theory of Operation

The Rectified Linear Unit (ReLU) is a widely used activation function in deep learning and neural network architectures. The ReLU function is defined as `f(x) = max(0, x)`, where the output is set to zero if the input is negative, and the input is passed through unchanged if the input is non-negative.

The `pipelined_relu` module implements a two-stage pipelined version of the ReLU activation function. The module takes a `DATA_WIDTH`-bit input `din` and produces a `DATA_WIDTH`-bit output `dout`. The pipelined design consists of two stages:

1. **Stage 1**: The first stage checks the sign bit of the input `din`. If the input is negative (i.e., the most significant bit is 1), the output of this stage is set to zero. Otherwise, the input is passed through unchanged.

2. **Stage 2**: The second stage simply passes the processed data from the first stage to the output `dout`.

The pipelined design allows for higher operating frequencies by breaking the critical path into two smaller, less complex stages. This can be beneficial in high-performance applications where low latency and high throughput are essential.

## Simulation Results

The provided testbench `pipelined_relu_tb` verifies the functionality of the `pipelined_relu` module. The testbench applies various input values (positive, negative, and zero) and checks the correctness of the output. The simulation results are as follows:

1. **Positive values**: When a positive value (e.g., `16'h0005`) is applied as the input, the output is correctly set to the same positive value (`16'h0005`).

2. **Negative values**: When a negative value (e.g., `16'hFFF5`) is applied as the input, the output is correctly set to zero (`16'h0000`).

3. **Zero value**: When a zero value (`16'h0000`) is applied as the input, the output is correctly set to zero (`16'h0000`).

All the tests in the testbench pass, and the message "TEST PASSED" is displayed, indicating that the `pipelined_relu` module is functioning as expected.