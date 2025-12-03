module dual_port_register_file_8x4 (
    input wire clk,
    input wire rst_n,
    input wire wr_en,
    input wire [2:0] wr_addr,
    input wire [3:0] wr_data,
    input wire [2:0] rd_addr_a,
    input wire [2:0] rd_addr_b,
    output reg [3:0] rd_data_a,
    output reg [3:0] rd_data_b
);

    // Register file array: 8 registers x 4 bits each
    reg [3:0] reg_file [0:7];
    
    integer i;
    
    // Write operation (synchronous)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all registers to 0
            for (i = 0; i < 8; i = i + 1) begin
                reg_file[i] <= 4'b0000;
            end
        end else if (wr_en) begin
            reg_file[wr_addr] <= wr_data;
        end
    end
    
    // Read operations (asynchronous)
    always @(*) begin
        rd_data_a = reg_file[rd_addr_a];
        rd_data_b = reg_file[rd_addr_b];
    end

endmodule