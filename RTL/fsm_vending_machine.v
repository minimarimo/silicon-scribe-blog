module vending_machine_controller (
    input  wire        clk,
    input  wire        reset,
    input  wire        coin_inserted,
    input  wire        product_selected,
    output reg         vend_product,
    output reg         change_returned
);

    // States
    localparam IDLE       = 2'b00;
    localparam COIN_WAIT  = 2'b01;
    localparam VEND       = 2'b10;
    localparam CHANGE     = 2'b11;

    reg [1:0] state, next_state;

    // State transition logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // Next state logic
    always @(*) begin
        case (state)
            IDLE: begin
                if (coin_inserted) begin
                    next_state = COIN_WAIT;
                end else begin
                    next_state = IDLE;
                end
            end
            COIN_WAIT: begin
                if (product_selected) begin
                    next_state = VEND;
                end else begin
                    next_state = COIN_WAIT;
                end
            end
            VEND: begin
                next_state = CHANGE;
            end
            CHANGE: begin
                next_state = IDLE;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // Output logic
    always @(*) begin
        case (state)
            IDLE: begin
                vend_product = 1'b0;
                change_returned = 1'b0;
            end
            COIN_WAIT: begin
                vend_product = 1'b0;
                change_returned = 1'b0;
            end
            VEND: begin
                vend_product = 1'b1;
                change_returned = 1'b0;
            end
            CHANGE: begin
                vend_product = 1'b0;
                change_returned = 1'b1;
            end
            default: begin
                vend_product = 1'b0;
                change_returned = 1'b0;
            end
        endcase
    end

endmodule