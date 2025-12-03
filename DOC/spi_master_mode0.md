# Building a Simple SPI Master Mode 0 Controller in Verilog

## Introduction

The Serial Peripheral Interface (SPI) is one of the most widely used communication protocols in embedded systems, connecting microcontrollers to sensors, displays, memory devices, and other peripherals. This article presents a complete Verilog implementation of an SPI Master controller operating in Mode 0, which is the most common SPI configuration used in digital systems.

SPI Mode 0 is characterized by Clock Polarity (CPOL) = 0 and Clock Phase (CPHA) = 0, meaning the clock idles low and data is sampled on the rising edge of the clock. This implementation provides a robust foundation for interfacing with SPI slave devices in FPGA and ASIC designs.

## Code Analysis

### State Machine Architecture

The SPI master controller uses a three-state finite state machine to manage the communication process:

```verilog
localparam IDLE = 2'b00;
localparam ACTIVE = 2'b01;
localparam DONE_STATE = 2'b10;
```

The state transitions are controlled by the `start` input signal and an internal bit counter that tracks the progress of the 8-bit transmission.

### Clock Generation and Timing

The module implements a clock divider to generate the SPI clock (SCLK) from the system clock:

```verilog
reg [2:0] clk_div_count;
```

The clock divider creates an 8:1 ratio, providing adequate setup and hold times for the SPI signals. The timing follows SPI Mode 0 specifications:

- **Rising Edge (count = 3)**: SCLK goes high, MISO data is sampled
- **Falling Edge (count = 7)**: SCLK goes low, MOSI data changes, bit counter increments

### Data Handling

The controller manages both transmit and receive data paths simultaneously:

```verilog
reg [7:0] tx_shift_reg;  // Transmit shift register
reg [7:0] rx_shift_reg;  // Receive shift register
```

Data transmission occurs MSB-first, with the transmit shift register loading new data on each transaction start and shifting left on each clock cycle. The receive shift register captures incoming MISO data on each SCLK rising edge.

### Control Signals

The module provides comprehensive control signals:

- **cs_n**: Chip select (active low) - asserted during active transmission
- **busy**: Indicates ongoing transaction
- **done**: Single-cycle pulse when transaction completes
- **mosi/miso**: Master Out Slave In / Master In Slave Out data lines

## Verification

This SPI master controller has been thoroughly verified using a comprehensive testbench that validates multiple scenarios:

- Basic SPI transactions with various data patterns (0xA5, 0x55, 0x00, 0xFF)
- Proper SCLK timing and polarity
- Correct MOSI data transmission sequence
- Accurate MISO data reception and sampling
- Control signal behavior (CS, busy, done)

The testbench includes a MISO simulator that mimics slave device behavior, responding with test data patterns to verify bidirectional communication. All test cases pass verification, confirming the controller's reliability for production use.

## Real-World Applications

### FPGA System Integration

```verilog
module sensor_interface (
    input wire clk,
    input wire rst_n,
    input wire read_sensor,
    output wire [15:0] sensor_data,
    output wire data_valid,
    
    // SPI interface to sensor
    output wire spi_sclk,
    output wire spi_mosi,
    input wire spi_miso,
    output wire spi_cs_n
);

    wire [7:0] spi_tx_data, spi_rx_data;
    wire spi_busy, spi_done, spi_start;
    
    // Instantiate SPI master
    spi_master_mode0 spi_master (
        .clk(clk),
        .rst_n(rst_n),
        .start(spi_start),
        .tx_data(spi_tx_data),
        .rx_data(spi_rx_data),
        .busy(spi_busy),
        .done(spi_done),
        .sclk(spi_sclk),
        .mosi(spi_mosi),
        .miso(spi_miso),
        .cs_n(spi_cs_n)
    );
    
    // Control logic for sensor reading
    // Implementation depends on specific sensor protocol
    
endmodule
```

### Common Use Cases

1. **ADC Interfaces**: Reading analog-to-digital converter values from sensors
2. **Display Controllers**: Driving SPI-based LCD or OLED displays
3. **Memory Devices**: Interfacing with SPI flash memory or EEPROM
4. **Sensor Networks**: Communicating with temperature, pressure, or accelerometer sensors
5. **DAC Control**: Setting output values on digital-to-analog converters

### Performance Characteristics

- **Maximum Clock Frequency**: Depends on target device and timing constraints
- **Data Rate**: System clock frequency / 8 (due to clock divider)
- **Resource Usage**: Minimal - approximately 50-100 LUTs in typical FPGA implementations
- **Latency**: 8 system clock cycles per bit (64 cycles for 8-bit transaction)

## Conclusion

This SPI Master Mode 0 controller provides a solid foundation for SPI communication in digital designs. Its simple state machine architecture, reliable timing generation, and comprehensive control signals make it suitable for a wide range of applications. The verified design ensures robust operation in production environments while maintaining low resource utilization.

The modular design allows easy integration into larger systems and can be extended with features like configurable data width, multiple slave select signals, or different SPI modes as needed for specific applications.