module spi_master_mode0 (
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire [7:0] tx_data,
    output reg [7:0] rx_data,
    output reg busy,
    output reg done,
    output reg sclk,
    output reg mosi,
    input wire miso,
    output reg cs_n
);

    // State machine states
    localparam IDLE = 2'b00;
    localparam ACTIVE = 2'b01;
    localparam DONE_STATE = 2'b10;
    
    reg [1:0] state, next_state;
    reg [3:0] bit_count;
    reg [7:0] tx_shift_reg;
    reg [7:0] rx_shift_reg;
    reg [2:0] clk_div_count;
    reg sclk_reg;
    
    // State machine
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    
    always @(*) begin
        case (state)
            IDLE: begin
                if (start)
                    next_state = ACTIVE;
                else
                    next_state = IDLE;
            end
            ACTIVE: begin
                if (bit_count == 4'd8 && clk_div_count == 3'd7)
                    next_state = DONE_STATE;
                else
                    next_state = ACTIVE;
            end
            DONE_STATE: begin
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end
    
    // Clock divider and SPI logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            busy <= 1'b0;
            done <= 1'b0;
            sclk <= 1'b0;
            sclk_reg <= 1'b0;
            mosi <= 1'b0;
            cs_n <= 1'b1;
            bit_count <= 4'd0;
            tx_shift_reg <= 8'h00;
            rx_shift_reg <= 8'h00;
            rx_data <= 8'h00;
            clk_div_count <= 3'd0;
        end else begin
            case (state)
                IDLE: begin
                    busy <= 1'b0;
                    done <= 1'b0;
                    sclk <= 1'b0;
                    sclk_reg <= 1'b0;
                    cs_n <= 1'b1;
                    bit_count <= 4'd0;
                    clk_div_count <= 3'd0;
                    if (start) begin
                        tx_shift_reg <= tx_data;
                        rx_shift_reg <= 8'h00;
                        mosi <= tx_data[7]; // Set first bit immediately
                    end
                end
                ACTIVE: begin
                    busy <= 1'b1;
                    done <= 1'b0;
                    cs_n <= 1'b0;
                    
                    clk_div_count <= clk_div_count + 1;
                    
                    // SPI Mode 0: CPOL=0, CPHA=0
                    // Data is stable on falling edge, sampled on rising edge
                    case (clk_div_count)
                        3'd3: begin // Rising edge of SCLK
                            sclk <= 1'b1;
                            sclk_reg <= 1'b1;
                            // Sample MISO
                            rx_shift_reg <= {rx_shift_reg[6:0], miso};
                        end
                        3'd7: begin // Falling edge of SCLK
                            sclk <= 1'b0;
                            sclk_reg <= 1'b0;
                            clk_div_count <= 3'd0;
                            bit_count <= bit_count + 1;
                            // Shift and output next bit
                            tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                            if (bit_count < 4'd7) begin
                                mosi <= tx_shift_reg[6];
                            end
                        end
                    endcase
                end
                DONE_STATE: begin
                    busy <= 1'b0;
                    done <= 1'b1;
                    sclk <= 1'b0;
                    cs_n <= 1'b1;
                    rx_data <= rx_shift_reg;
                end
            endcase
        end
    end

endmodule