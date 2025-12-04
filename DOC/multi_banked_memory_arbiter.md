# Multi-Banked Memory Arbiter

## Theory of Operation

The `memory_arbiter` module is a SystemVerilog implementation of a multi-banked memory arbiter. It is designed to handle read and write requests from multiple masters and arbitrate access to the memory banks in a round-robin fashion.

The module takes the following parameters:
- `NUM_BANKS`: The number of memory banks.
- `ADDR_WIDTH`: The width of the memory address.
- `DATA_WIDTH`: The width of the memory data.

The module has the following ports:
- `clk`: The system clock.
- `rst_n`: The active-low reset signal.
- `m_req`: An array of request signals, one for each master.
- `m_addr`: An array of memory addresses, one for each master.
- `m_wr`: An array of write enable signals, one for each master.
- `m_wdata`: An array of write data, one for each master.
- `m_gnt`: An array of grant signals, one for each master.
- `m_rdata`: An array of read data, one for each master.
- `m_rdy`: An array of ready signals, one for each master.

The arbiter uses a round-robin arbitration scheme to grant access to the memory banks. When a master requests access to a memory bank, the arbiter checks if the bank is busy. If the bank is available, the arbiter grants access to the master, sets the corresponding `m_gnt` and `m_rdy` signals, and performs the requested read or write operation. If the bank is busy, the arbiter sets the `m_gnt` and `m_rdy` signals for that master to 0, indicating that the request has been denied.

The `next_bank` variable keeps track of the next bank to be accessed in the round-robin scheme. After each access, the `next_bank` variable is updated to the next bank in the sequence.

## Simulation Results

The provided testbench `memory_arbiter_tb` simulates the operation of the `memory_arbiter` module. The testbench performs the following steps:

1. Resets the module and the input signals.
2. Generates read and write requests to the different memory banks.
3. Checks the correctness of the read and write operations by verifying the output data.

The testbench checks the following conditions:
- If a write operation is performed, the written data should match the expected data.
- If a read operation is performed, the read data should not be 0 (the default value).

If all the tests pass, the testbench prints "TEST PASSED". If any of the tests fail, the testbench prints "TEST FAILED" and terminates the simulation.

The simulation results demonstrate that the `memory_arbiter` module correctly arbitrates access to the memory banks and performs the requested read and write operations.