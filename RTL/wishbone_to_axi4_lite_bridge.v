`timescale 1ns/1ps

module wb_to_axi4_lite_bridge #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter TIMEOUT = 1000
) (
    // Wishbone Slave Interface
    input  wire                  wb_clk_i,
    input  wire                  wb_rst_i,
    input  wire                  wb_stb_i,
    input  wire                  wb_we_i,
    input  wire [ADDR_WIDTH-1:0] wb_adr_i,
    input  wire [DATA_WIDTH-1:0] wb_dat_i,
    output reg  [DATA_WIDTH-1:0] wb_dat_o,
    output reg                   wb_ack_o,

    // AXI4-Lite Master Interface
    output reg                   axi_awvalid,
    output reg  [ADDR_WIDTH-1:0] axi_awaddr,
    input  wire                  axi_awready,
    output reg                   axi_wvalid,
    output reg  [DATA_WIDTH-1:0] axi_wdata,
    output reg  [DATA_WIDTH/8-1:0] axi_wstrb,
    input  wire                  axi_wready,
    input  wire                  axi_bvalid,
    input  wire [1:0]            axi_bresp,
    output reg                   axi_bready,
    output reg                   axi_arvalid,
    output reg  [ADDR_WIDTH-1:0] axi_araddr,
    input  wire                  axi_arready,
    input  wire                  axi_rvalid,
    input  wire [DATA_WIDTH-1:0] axi_rdata,
    input  wire [1:0]            axi_rresp,
    output reg                   axi_rready
);

    // Internal state
    reg [1:0] state;
    localparam IDLE = 2'b00, WRITE = 2'b01, READ = 2'b10;

    always @(posedge wb_clk_i or posedge wb_rst_i) begin
        if (wb_rst_i) begin
            state <= IDLE;
            wb_dat_o <= 0;
            wb_ack_o <= 0;
            axi_awvalid <= 0;
            axi_wvalid <= 0;
            axi_bready <= 0;
            axi_arvalid <= 0;
            axi_rready <= 0;
        end else begin
            case (state)
                IDLE: begin
                    wb_ack_o <= 0;
                    if (wb_stb_i) begin
                        if (wb_we_i) begin
                            state <= WRITE;
                            axi_awvalid <= 1;
                            axi_awaddr <= wb_adr_i;
                            axi_wvalid <= 1;
                            axi_wdata <= wb_dat_i;
                            axi_wstrb <= {DATA_WIDTH/8{1'b1}};
                        end else begin
                            state <= READ;
                            axi_arvalid <= 1;
                            axi_araddr <= wb_adr_i;
                        end
                    end
                end
                WRITE: begin
                    if (axi_awready && axi_wready) begin
                        axi_awvalid <= 0;
                        axi_wvalid <= 0;
                        axi_bready <= 1;
                        state <= IDLE;
                        wb_ack_o <= 1;
                    end
                end
                READ: begin
                    if (axi_arready) begin
                        axi_arvalid <= 0;
                        axi_rready <= 1;
                    end
                    if (axi_rvalid) begin
                        wb_dat_o <= axi_rdata;
                        axi_rready <= 0;
                        state <= IDLE;
                        wb_ack_o <= 1;
                    end
                end
            endcase
        end
    end

endmodule