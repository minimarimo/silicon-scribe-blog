module fsm_sequence_detector_1101 (
    input wire clk,
    input wire rst_n,
    input wire data_in,
    output reg detected
);

    // State encoding for detecting sequence 1101
    reg [2:0] current_state, next_state;
    
    localparam IDLE  = 3'b000;  // Initial state
    localparam S1    = 3'b001;  // Detected first '1'
    localparam S11   = 3'b010;  // Detected '11'
    localparam S110  = 3'b011;  // Detected '110'
    
    // State register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end
    
    // Next state logic
    always @(*) begin
        case (current_state)
            IDLE: begin
                if (data_in == 1'b1)
                    next_state = S1;
                else
                    next_state = IDLE;
            end
            
            S1: begin
                if (data_in == 1'b1)
                    next_state = S11;
                else
                    next_state = IDLE;
            end
            
            S11: begin
                if (data_in == 1'b0)
                    next_state = S110;
                else
                    next_state = S11; // Stay in S11 for consecutive 1s
            end
            
            S110: begin
                if (data_in == 1'b1)
                    next_state = S1; // Go to S1 for potential overlapping
                else
                    next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    // Output logic - detect when we complete the sequence
    // Register the detection to align with clock edge
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            detected <= 1'b0;
        end else begin
            // Detect when transitioning from S110 to S1 (completing 1101)
            detected <= (current_state == S110) && (data_in == 1'b1);
        end
    end

endmodule