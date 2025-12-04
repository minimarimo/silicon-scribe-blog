# FIFO with Gray Code Pointers

## Theory of Operation

The `fifo_gray` module implements a First-In-First-Out (FIFO) buffer using Gray code pointers for the write and read operations. Gray code is a binary numeral system where two successive values differ in only one bit position. This property is beneficial for FIFO implementations, as it helps to avoid potential metastability issues that can arise when the write and read pointers cross the same memory location.

The module has the following key components:

1. **Memory**: A 2D array `mem` that stores the data elements.
2. **Write and Read Pointers**: The `write_ptr` and `read_ptr` registers hold the current write and read positions in the FIFO memory.
3. **Fill Level**: The `fill_level` register tracks the number of valid data elements in the FIFO.
4. **Flags**: The `full` and `empty` flags indicate the FIFO's state.

The Gray code pointer logic updates the `write_ptr` and `read_ptr` registers based on the `push` and `pop` operations, respectively. The FIFO logic handles the data storage and retrieval, updating the `fill_level` accordingly.

The `fifo_gray_tb` testbench demonstrates the FIFO's functionality by filling the FIFO, draining it, and verifying that the FIFO is empty at the end of the test.

## Simulation Results

The provided testbench performs the following steps:

1. Resets the FIFO.
2. Fills the FIFO by repeatedly pushing random data.
3. Drains the FIFO by repeatedly popping data.
4. Checks if the FIFO is empty at the end of the test.

The testbench output shows the following:

```
TEST PASSED
```

This indicates that the FIFO with Gray Code Pointers implementation is working as expected, and the FIFO is correctly emptied after the fill and drain operations.