`timescale 1ns/1ps

module apb3_bridge #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input wire                  pclk,
    input wire                  presetn,
    input wire [ADDR_WIDTH-1:0] paddr,
    input wire [DATA_WIDTH-1:0] pwdata,
    input wire                  pwrite,
    input wire                  psel,
    input wire                  penable,
    output reg [DATA_WIDTH-1:0] prdata,
    output reg                  pready,
    output reg                  pslverr
);

    reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];

    always @(posedge pclk or negedge presetn) begin
        if (~presetn) begin
            prdata <= {DATA_WIDTH{1'b0}};
            pready <= 1'b0;
            pslverr <= 1'b0;
        end else if (psel && penable) begin
            if (pwrite) begin
                mem[paddr[ADDR_WIDTH-1:0]] <= pwdata;
                pready <= 1'b1;
                pslverr <= 1'b0;
            end else begin
                prdata <= mem[paddr[ADDR_WIDTH-1:0]];
                pready <= 1'b1;
                pslverr <= 1'b0;
            end
        end else begin
            pready <= 1'b0;
            pslverr <= 1'b0;
        end
    end

endmodule