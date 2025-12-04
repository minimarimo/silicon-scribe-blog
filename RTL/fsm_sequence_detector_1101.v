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

    // State register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= S_IDLE;
        end else begin
            current_state <= next_state;
        end
    end

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

endmodule