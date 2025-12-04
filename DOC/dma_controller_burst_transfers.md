# DMA Controller with Burst Transfers

## Theory of Operation

The DMA (Direct Memory Access) Controller with Burst Transfers is a SystemVerilog module that facilitates the transfer of data between a source address and a destination address in a burst mode. This module is designed to optimize memory access by reducing the load on the CPU and improving overall system performance.

The key features of the DMA Controller include:

1. **Configurable Parameters**: The module supports configurable parameters for the data width (`DATA_WIDTH`), address width (`ADDR_WIDTH`), and burst length (`BURST_LEN`), allowing for flexibility in adapting to different system requirements.

2. **Burst Transfers**: The DMA Controller performs burst transfers, where multiple consecutive data words are transferred between the source and destination addresses. This reduces the overhead associated with individual memory access operations, improving the overall data transfer efficiency.

3. **Asynchronous Operation**: The DMA Controller operates asynchronously, allowing the CPU to continue with other tasks while the data transfer is in progress. The module provides a `done` signal to indicate the completion of the transfer.

4. **Address Incrementing**: The module automatically increments the source and destination addresses after each burst transfer, simplifying the integration with the system's memory subsystem.

The DMA Controller's operation can be summarized as follows:

1. The module waits for the `start` signal to be asserted, indicating the beginning of a data transfer.
2. Once the `start` signal is received, the module loads the source address (`src_addr`), destination address (`dst_addr`), and burst length (`burst_len`) from the input signals.
3. The module then initiates the data transfer by asserting the `read_en` and `write_en` signals, and incrementing the current source and destination addresses (`curr_src_addr` and `curr_dst_addr`) after each burst transfer.
4. The module keeps track of the remaining burst length (`curr_burst_len`) and decrements it after each transfer.
5. Once the entire burst transfer is complete, the module asserts the `done` signal to indicate the successful completion of the data transfer.

## Simulation Results

The provided testbench verifies the functionality of the DMA Controller with Burst Transfers. The testbench initializes the necessary input signals, starts the DMA transfer, and waits for the `done` signal to be asserted. It then checks the final values of the current source address, current destination address, and current burst length to ensure that the DMA transfer was successful.

The simulation results show that the DMA Controller correctly performs the burst transfer between the specified source and destination addresses, and the final values of the current addresses and burst length match the expected results.

```
TEST PASSED
```

The successful test result demonstrates that the DMA Controller with Burst Transfers module is functioning as expected, providing an efficient mechanism for data transfer between memory locations in a system-on-chip (SoC) or other embedded systems.