import "DPI-C" context function void c_aes_process(
  input  bit [127:0] key,
  input  bit [127:0] iv,
  input  bit [127:0] din,
  output bit [127:0] dout,
  input  int         mode,
  input  int         is_decrypt
);

class minisoc_scb extends uvm_scoreboard;
  `uvm_component_utils(minisoc_scb)

  `uvm_analysis_imp_decl(_mem)
  uvm_analysis_imp_mem #(mem_data_item, minisoc_scb) mem_export;

  localparam bit [15:0] ADDR_KEY   = 16'hA000;
  localparam bit [15:0] ADDR_IV    = 16'hA010;
  localparam bit [15:0] ADDR_DIN   = 16'hA020;
  localparam bit [15:0] ADDR_DOUT  = 16'hA030;
  localparam bit [15:0] ADDR_CTRL  = 16'hA040;

  bit [127:0] current_key;
  bit [127:0] current_iv;
  bit [127:0] current_din;
  int         current_mode;
  int         current_is_decrypt;

  bit [127:0] expected_fifo[$];

  int match_count    = 0;
  int mismatch_count = 0;

  function new(string name = "minisoc_scb", uvm_component parent = null);
    super.new(name, parent);
    mem_export = new("mem_export", this);
  endfunction : new

  function void write_mem(mem_data_item item);
    bit [127:0] expected_data;

    if (item.we) begin
      case (item.addr)
        ADDR_KEY:  current_key = {current_key[95:0], item.wdata};
        ADDR_IV:   current_iv  = {current_iv[95:0], item.wdata};
        ADDR_DIN:  current_din = {current_din[95:0], item.wdata};

        ADDR_CTRL: begin
          current_is_decrypt = item.wdata[0];
          current_mode       = item.wdata[3:1];

          c_aes_process(
            current_key,
            current_iv,
            current_din,
            expected_data,
            current_mode,
            current_is_decrypt
          );

          `uvm_info(get_type_name(), $sformatf("Refmod C++ calculado! Expected Output: 0x%0h (Mode: %0d, Decrypt: %0d)", 
                    expected_data, current_mode, current_is_decrypt), UVM_MEDIUM)

          expected_fifo.push_back(expected_data);
        end
      endcase

    end else begin
      if (item.addr == ADDR_DOUT) begin
        if (expected_fifo.size() == 0) begin
          `uvm_error("SCB_UNEXPECTED_READ", "DUT retornou dado em DOUT mas a FIFO do Refmod esta vazia!")
        end else begin
          expected_data = expected_fifo.pop_front();

          if (item.rdata === expected_data[31:0]) begin
            match_count++;
            `uvm_info("SCB_MATCH", $sformatf("SUCESSO: DUT Output 0x%0h bateu com C++ Refmod!", item.rdata), UVM_LOW)
          end else begin
            mismatch_count++;
            `uvm_error("SCB_MISMATCH", $sformatf("ERRO AES! DUT: 0x%0h | Esperado (C++ Refmod): 0x%0h", 
                       item.rdata, expected_data[31:0]))
          end
        end
      end
    end
  endfunction : write_mem

  function void check_phase(uvm_phase phase);
    super.check_phase(phase);
    if (expected_fifo.size() > 0) begin
      `uvm_error("SCB_PENDING_DATA", $sformatf("Existem %0d blocos esperados que nao foram lidos do DUT!", expected_fifo.size()))
    end
    `uvm_info("SCB_SUMMARY", $sformatf("Relatorio de Verificacao AES: %0d Sucessos, %0d Erros", match_count, mismatch_count), UVM_NONE)
  endfunction : check_phase

endclass : minisoc_scb