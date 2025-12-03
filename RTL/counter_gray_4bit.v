module gray_counter_4bit (
    input wire clk,
    input wire reset,
    output reg [3:0] gray_count
);

    reg [3:0] binary_count;
    
    // Binary counter
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            binary_count <= 4'b0000;
        end else begin
            binary_count <= binary_count + 1;
        end
    end
    
    // Binary to Gray code conversion
    always @(*) begin
        gray_count[3] = binary_count[3];
        gray_count[2] = binary_count[3] ^ binary_count[2];
        gray_count[1] = binary_count[2] ^ binary_count[1];
        gray_count[0] = binary_count[1] ^ binary_count[0];
    end

endmodule