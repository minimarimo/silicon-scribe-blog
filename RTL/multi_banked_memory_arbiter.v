`timescale 1ns/1ps

module memory_arbiter #(
    parameter NUM_BANKS = 4,
    parameter ADDR_WIDTH = 16,
    parameter DATA_WIDTH = 32
) (
    input logic clk,
    input logic rst_n,

    // Master Interfaces
    input logic [NUM_BANKS-1:0] m_req,
    input logic [NUM_BANKS-1:0][ADDR_WIDTH-1:0] m_addr,
    input logic [NUM_BANKS-1:0] m_wr,
    input logic [NUM_BANKS-1:0][DATA_WIDTH-1:0] m_wdata,
    output logic [NUM_BANKS-1:0] m_gnt,
    output logic [NUM_BANKS-1:0][DATA_WIDTH-1:0] m_rdata,
    output logic [NUM_BANKS-1:0] m_rdy
);

    logic [NUM_BANKS-1:0] bank_busy;
    logic [$clog2(NUM_BANKS)-1:0] next_bank;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bank_busy <= '0;
            next_bank <= '0;
        end else begin
            for (int i = 0; i < NUM_BANKS; i++) begin
                if (m_req[i]) begin
                    if (!bank_busy[i]) begin
                        bank_busy[i] <= 1'b1;
                        m_gnt[i] <= 1'b1;
                        m_rdy[i] <= 1'b1;
                        if (m_wr[i]) begin
                            // Write operation
                            // Access memory bank i and write m_wdata[i]
                        end else begin
                            // Read operation
                            // Access memory bank i and assign m_rdata[i]
                        end
                    end else begin
                        m_gnt[i] <= 1'b0;
                        m_rdy[i] <= 1'b0;
                    end
                end else begin
                    bank_busy[i] <= 1'b0;
                    m_gnt[i] <= 1'b0;
                    m_rdy[i] <= 1'b0;
                end
            end

            // Round-robin arbitration
            next_bank <= (next_bank == NUM_BANKS - 1) ? '0 : next_bank + 1;
        end
    end

endmodule