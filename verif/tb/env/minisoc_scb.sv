import "DPI-C" context function void c_aes_process(
  input bit [127:0] key,
  input bit [127:0] iv,
  input bit [127:0] din,
  output bit [127:0] dout,
  input int mode,
  input int is_decrypt
);

`uvm_analysis_imp_decl(_mem)
`uvm_analysis_imp_decl(_spi)

class minisoc_scb extends uvm_scoreboard;
  `uvm_component_utils(minisoc_scb)

  uvm_analysis_imp_mem #(mem_data_item, minisoc_scb) mem_export;
  uvm_analysis_imp_spi #(spi_item, minisoc_scb) spi_export;

  bit [127:0] current_key;
  bit [127:0] current_iv;
  bit [127:0] current_din;

  int current_mode;
  int current_is_decrypt;

  bit [31:0] expected_words[$];
  int unsigned expected_addresses[$];

  int match_count = 0;
  int mismatch_count = 0;
  int refmodel_count = 0;

  function new(string name = "minisoc_scb", uvm_component parent = null);
    super.new(name, parent);
    mem_export = new("mem_export", this);
    spi_export = new("spi_export", this);
    current_key = '0;
    current_iv = '0;
    current_din = '0;
    current_mode = 0;
    current_is_decrypt = 0;
  endfunction

  function void write_spi(spi_item item);
    bit [127:0] expected_block;

    if (item.op != spi_item::SPI_WRITE)
      return;

    case (item.addr)
      6'h00: current_key[127:96] = item.data;
      6'h01: current_key[95:64]  = item.data;
      6'h02: current_key[63:32]  = item.data;
      6'h03: current_key[31:0]   = item.data;
      6'h04: current_iv[127:96] = item.data;
      6'h05: current_iv[95:64]  = item.data;
      6'h06: current_iv[63:32]  = item.data;
      6'h07: current_iv[31:0]   = item.data;

      6'h0B: begin
        current_is_decrypt = item.data[1];
        current_mode = item.data[4:2];

        if (item.data[0]) begin
          expected_block = '0;

          if (expected_words.size() != 0) begin
            `uvm_error("SCB_PENDING_DATA",
              "Novo START recebido antes de consumir todos os resultados esperados")
            expected_words.delete();
            expected_addresses.delete();
          end

          c_aes_process(
            current_key,
            current_iv,
            current_din,
            expected_block,
            current_mode,
            current_is_decrypt
          );

          expected_words.push_back(expected_block[127:96]);
          expected_words.push_back(expected_block[95:64]);
          expected_words.push_back(expected_block[63:32]);
          expected_words.push_back(expected_block[31:0]);

          expected_addresses.push_back(0);
          expected_addresses.push_back(1);
          expected_addresses.push_back(2);
          expected_addresses.push_back(3);

          refmodel_count++;

          `uvm_info("SCB_REFMODEL",
            $sformatf(
              "\n======================================================================\nREF MODEL C++ - AES\n======================================================================\n[SCB_REFMODEL] Chave    : %032h\n[SCB_REFMODEL] Entrada  : %032h\n[SCB_REFMODEL] Modo     : %0d\n[SCB_REFMODEL] Operacao : %s\n----------------------------------------------------------------------\n[SCB_REFMODEL] Resultado esperado:\n[SCB_REFMODEL] %032h\n======================================================================",
              current_key,
              current_din,
              current_mode,
              current_is_decrypt ? "Descriptografia" : "Criptografia",
              expected_block
            ),
            UVM_MEDIUM)
        end
      end

      default: begin
      end
    endcase
  endfunction

  function void write_mem(mem_data_item item);
    bit [31:0] expected_word;
    int unsigned expected_addr;

    if (item.we) begin
      case (item.addr)
        10'd0: current_din[127:96] = item.wdata;
        10'd1: current_din[95:64]  = item.wdata;
        10'd2: current_din[63:32]  = item.wdata;
        10'd3: current_din[31:0]   = item.wdata;
        default: begin
        end
      endcase
      return;
    end

    if (item.addr > 10'd3)
      return;

    if (expected_words.size() == 0) begin
      mismatch_count++;
      `uvm_error("SCB_UNEXPECTED_READ",
        $sformatf(
          "\n----------------------------------------------------------------------\n[SCB_MISMATCH] Leitura sem resultado esperado\n[SCB_MISMATCH] Endereco: 0x%03h\n[SCB_MISMATCH] DUT      : %08h\n----------------------------------------------------------------------",
          item.addr,
          item.rdata
        ))
      return;
    end

    expected_word = expected_words.pop_front();
    expected_addr = expected_addresses.pop_front();

    if (item.addr != expected_addr) begin
      mismatch_count++;
      `uvm_error("SCB_ADDRESS_MISMATCH",
        $sformatf(
          "\n----------------------------------------------------------------------\n[SCB_MISMATCH] Endereco incorreto\n[SCB_MISMATCH] Esperado: 0x%03h\n[SCB_MISMATCH] Recebido: 0x%03h\n----------------------------------------------------------------------",
          expected_addr,
          item.addr
        ))
    end

    if (item.rdata === expected_word) begin
      match_count++;
      `uvm_info("SCB_MATCH",
        $sformatf(
          "[SCB_MATCH] PASS | Addr: 0x%03h | DUT: %08h | REF: %08h",
          item.addr,
          item.rdata,
          expected_word
        ),
        UVM_LOW)
    end
    else begin
      mismatch_count++;
      `uvm_error("SCB_MISMATCH",
        $sformatf(
          "\n----------------------------------------------------------------------\n[SCB_MATCH] FAIL | Divergencia detectada\n[SCB_MATCH] Endereco: 0x%03h\n[SCB_MATCH] DUT      : %08h\n[SCB_MATCH] Ref Model: %08h\n----------------------------------------------------------------------",
          item.addr,
          item.rdata,
          expected_word
        ))
    end
  endfunction

  function void check_phase(uvm_phase phase);
    string result;

    super.check_phase(phase);

    if (refmodel_count == 0) begin
      `uvm_error("SCB_NO_REFMODEL",
        "O Ref Model C nao foi executado durante o teste")
    end

    if (expected_words.size() != 0) begin
      `uvm_error("SCB_PENDING_DATA",
        $sformatf(
          "Restam %0d palavras esperadas que nao foram lidas do DUT",
          expected_words.size()
        ))
    end

    result = (refmodel_count > 0 &&
              mismatch_count == 0 &&
              expected_words.size() == 0) ? "PASS" : "FAIL";

    `uvm_info("SCB_SUMMARY",
      $sformatf(
        "\n======================================================================\nRESUMO DO SCOREBOARD\n======================================================================\n[SCB_SUMMARY] Chamadas ao Ref Model: %0d\n[SCB_SUMMARY] Comparacoes aprovadas: %0d\n[SCB_SUMMARY] Divergencias: %0d\n[SCB_SUMMARY] Palavras pendentes: %0d\n----------------------------------------------------------------------\n[SCB_SUMMARY] RESULTADO: %s\n======================================================================",
        refmodel_count,
        match_count,
        mismatch_count,
        expected_words.size(),
        result
      ),
      UVM_NONE)
  endfunction

endclass