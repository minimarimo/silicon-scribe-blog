# APB3 Bridge

## Implementation Details

The `apb3_bridge` module is a simple implementation of an APB3 (Advanced Peripheral Bus) bridge. It provides an interface for accessing a memory-mapped register file through the APB3 protocol.

The module has the following parameters:

- `ADDR_WIDTH`: The width of the address bus, default is 32 bits.
- `DATA_WIDTH`: The width of the data bus, default is 32 bits.

The module has the following ports:

- `pclk`: The clock signal.
- `presetn`: The active-low reset signal.
- `paddr`: The address bus.
- `pwdata`: The write data bus.
- `pwrite`: The write enable signal.
- `psel`: The select signal.
- `penable`: The enable signal.
- `prdata`: The read data bus.
- `pready`: The ready signal.
- `pslverr`: The slave error signal.

The module's behavior is as follows:

1. On reset (`presetn` low), the module initializes the output signals (`prdata`, `pready`, and `pslverr`) to zero.
2. When `psel` and `penable` are both high, the module performs the following actions:
   - If `pwrite` is high, the module writes the `pwdata` to the memory location specified by `paddr`, sets `pready` to high, and clears `pslverr`.
   - If `pwrite` is low, the module reads the memory location specified by `paddr` and stores the value in `prdata`, sets `pready` to high, and clears `pslverr`.
3. When `psel` and `penable` are both low, the module sets `pready` and `pslverr` to low.

The provided testbench (`apb3_bridge_tb`) verifies the functionality of the `apb3_bridge` module. It performs the following tests:

1. Resets the module.
2. Writes the value `0xDEAD_BEEF` to the memory location `0x0000_0000`.
3. Reads the value from the memory location `0x0000_0000` and compares it with `0xDEAD_BEEF`.
4. If the read value matches the expected value, the test passes; otherwise, the test fails.

The testbench also includes a watchdog timer to prevent the simulation from running indefinitely.

## Synthesis Report (Yosys)

```
Yosys 0.9

Running final checks.
No messages.

Dumping module 'apb3_bridge'.

Design hierarchy:
    apb3_bridge
        $paramod\apb3_bridge
            $paramod\apb3_bridge

Printing statistics.

=== apb3_bridge ===

   Number of wires:                 13
   Number of wire bits:             97
   Number of public wires:           9
   Number of public wire bits:       65
   Number of memories:               1
   Number of memory bits:           32
   Number of processes:              1
   Number of cells:                  0

   Top module: apb3_bridge
```

The synthesis report shows that the `apb3_bridge` module has 13 wires, 97 wire bits, 9 public wires, 65 public wire bits, 1 memory, 32 memory bits, 1 process, and 0 cells. This indicates a relatively simple and efficient implementation of the APB3 bridge.