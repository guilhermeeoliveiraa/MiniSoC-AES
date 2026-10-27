`include "uvm_macros.svh"
import uvm_pkg::*;

module top_assertions (
  input wire logic clk,
  input wire logic rst_n,
  input wire logic spi_cs_n,
  input wire logic spi_sclk
);

  default clocking def_cb @(posedge clk); endclocking
  default disable iff (!rst_n);

  property p_reset_active;
    disable iff (1'b0)
    !rst_n |-> ##1 (spi_cs_n == 1'b1);
  endproperty

  a_reset_active: assert property (p_reset_active)
    else `uvm_error("SVA_RST_FAIL", "DUT state not idle during active reset!")

  property p_spi_cs_stability;
    $fell(spi_cs_n) |-> ##1 (spi_sclk inside {1'b0, 1'b1});
  endproperty

  a_spi_cs_stability: assert property (p_spi_cs_stability)
    else `uvm_error("SVA_SPI_CS_FAIL", "SPI CS_N glitched or invalid state transition!")

  c_reset_asserted: cover property (!rst_n);
  c_spi_transaction_start: cover property ($fell(spi_cs_n));

endmodule : top_assertions