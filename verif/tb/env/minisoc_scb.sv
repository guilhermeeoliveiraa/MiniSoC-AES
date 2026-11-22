
import "DPI-C" context function void c_aes_process(
  input  bit [127:0] key,
  input  bit [127:0] iv,
  input  bit [127:0] din,
  output bit [127:0] dout,
  input  int mode,
  input  int is_decrypt
);


`uvm_analysis_imp_decl(_mem)
`uvm_analysis_imp_decl(_spi)


class minisoc_scb extends uvm_scoreboard;

  `uvm_component_utils(minisoc_scb)


  // Portas de analise dos monitores
  uvm_analysis_imp_mem #(mem_data_item, minisoc_scb) mem_export;
  uvm_analysis_imp_spi #(spi_item, minisoc_scb) spi_export;


  // Configuracoes observadas do AES
  bit [127:0] current_key;
  bit [127:0] current_iv;
  bit [127:0] current_din;

  int current_mode;
  int current_is_decrypt;


  // Controle de validade dos dados
  bit [3:0] key_word_valid;
  bit [3:0] input_word_valid;


  // Estado de ownership da memoria
  bit mem_sel_aes;


  // Resultados esperados
  bit [127:0] expected_block;
  bit [31:0] expected_words[$];
  int unsigned expected_addresses[$];


  // Bloco recebido do DUT
  bit [127:0] dut_block;

  // Controle de validade das palavras recebidas
  bit [3:0] dut_word_valid;


  // Contadores de verificacao
  int unsigned match_count;
  int unsigned mismatch_count;
  int unsigned refmodel_count;


  // Construtor
  function new(string name = "minisoc_scb",
               uvm_component parent = null);

    super.new(name, parent);

    mem_export = new("mem_export", this);
    spi_export = new("spi_export", this);

    current_key = '0;
    current_iv = '0;
    current_din = '0;

    current_mode = 0;
    current_is_decrypt = 0;

    key_word_valid = '0;
    input_word_valid = '0;

    mem_sel_aes = 1'b0;

    expected_block = '0;
    dut_block = '0;
    dut_word_valid = '0;

    match_count = 0;
    mismatch_count = 0;
    refmodel_count = 0;

  endfunction : new


  // Recebe e processa transacoes SPI
  function void write_spi(spi_item item);

    // Considera somente transacoes de escrita
    if (item.op != spi_item::SPI_WRITE)
      return;


    case (item.addr)

      // Registradores da chave AES
      6'h00: begin
        current_key[127:96] = item.data;
        key_word_valid[0] = 1'b1;
      end

      6'h01: begin
        current_key[95:64] = item.data;
        key_word_valid[1] = 1'b1;
      end

      6'h02: begin
        current_key[63:32] = item.data;
        key_word_valid[2] = 1'b1;
      end

      6'h03: begin
        current_key[31:0] = item.data;
        key_word_valid[3] = 1'b1;
      end


      // Registradores do vetor de inicializacao
      6'h04: current_iv[127:96] = item.data;
      6'h05: current_iv[95:64]  = item.data;
      6'h06: current_iv[63:32]  = item.data;
      6'h07: current_iv[31:0]   = item.data;


      // Registrador de controle do sistema
      6'h0E: begin
        mem_sel_aes = item.data[0];
      end


      // Registrador de controle do AES
      6'h0B: begin

        current_is_decrypt = item.data[1];
        current_mode = item.data[4:2];

        // Verifica se foi solicitado START
        if (item.data[0]) begin

          // Verifica se existem resultados anteriores pendentes
          if (expected_words.size() != 0 ||
              expected_addresses.size() != 0) begin

            mismatch_count++;

            `uvm_error("SCB_PENDING_DATA",
              "Novo START recebido antes de consumir todos os resultados esperados")

            expected_words.delete();
            expected_addresses.delete();

            dut_block = '0;
            dut_word_valid = '0;

          end


          // Verifica se a chave foi completamente configurada
          if (key_word_valid != 4'b1111) begin

            mismatch_count++;

            `uvm_error("SCB_INVALID_KEY",
              "START recebido sem todos os words da chave AES configurados")

            return;

          end


          // Verifica se o bloco de entrada foi completamente carregado
          if (input_word_valid != 4'b1111) begin

            mismatch_count++;

            `uvm_error("SCB_INVALID_INPUT",
              "START recebido sem todos os words do bloco de entrada")

            return;

          end


          // Inicializa o resultado esperado
          expected_block = '0;


          // Executa o modelo de referencia C++
          c_aes_process(
            current_key,
            current_iv,
            current_din,
            expected_block,
            current_mode,
            current_is_decrypt
          );


          // Armazena as palavras esperadas
          expected_words.push_back(expected_block[127:96]);
          expected_words.push_back(expected_block[95:64]);
          expected_words.push_back(expected_block[63:32]);
          expected_words.push_back(expected_block[31:0]);


          // Associa cada palavra ao respectivo endereco
          expected_addresses.push_back(0);
          expected_addresses.push_back(1);
          expected_addresses.push_back(2);
          expected_addresses.push_back(3);


          // Inicializa o bloco recebido do DUT
          dut_block = '0;
          dut_word_valid = '0;


          // Atualiza o contador de chamadas ao modelo
          refmodel_count++;


          // Exibe os resultados do modelo de referencia
          `uvm_info("SCB_REFMODEL",
            $sformatf(
              "\n[SCB_REFMODEL] Modelo de referencia AES executado\n\
               Chave       : %032h\n\
               IV          : %032h\n\
               Entrada     : %032h\n\
               Modo        : %0d\n\
               Operacao    : %s\n\
               Resultado   : %032h",
              current_key,
              current_iv,
              current_din,
              current_mode,
              current_is_decrypt ? "Descriptografia" : "Criptografia",
              expected_block
            ),
            UVM_MEDIUM)


          // Exige um novo carregamento para a proxima operacao
          input_word_valid = '0;

        end

      end


      default: begin
      end

    endcase

  endfunction : write_spi


  // Recebe e processa transacoes da memoria
  function void write_mem(mem_data_item item);

    int match_idx;


    // Ignora transacoes sem habilitacao
    if (!item.en)
      return;


    // Processa escritas na memoria
    if (item.we) begin

      // Ignora escritas realizadas pelo AES
      if (mem_sel_aes)
        return;


      // Atualiza o bloco de entrada
      case (item.addr)

        10'd0: begin
          current_din[127:96] = item.wdata;
          input_word_valid[0] = 1'b1;
        end

        10'd1: begin
          current_din[95:64] = item.wdata;
          input_word_valid[1] = 1'b1;
        end

        10'd2: begin
          current_din[63:32] = item.wdata;
          input_word_valid[2] = 1'b1;
        end

        10'd3: begin
          current_din[31:0] = item.wdata;
          input_word_valid[3] = 1'b1;
        end

        default: begin
        end

      endcase

      return;

    end


    // Ignora leituras enquanto o AES possui a memoria
    if (mem_sel_aes)
      return;


    // Considera somente os enderecos do bloco esperado
    if (item.addr > 10'd3)
      return;


    // Verifica se existem resultados esperados
    if (expected_words.size() == 0 ||
        expected_addresses.size() == 0) begin

      mismatch_count++;

      `uvm_error("SCB_UNEXPECTED_READ",
        $sformatf(
          "[SCB_MISMATCH] Leitura sem resultado esperado\n\
           Endereco : 0x%03h\n\
           DUT      : %08h",
          item.addr,
          item.rdata
        ))

      return;

    end


    // Procura o endereco correspondente na fila
    match_idx = -1;

    for (int i = 0; i < expected_addresses.size(); i++) begin

      if (expected_addresses[i] == item.addr) begin
        match_idx = i;
        break;
      end

    end


    // Verifica se o endereco pertence ao resultado esperado
    if (match_idx == -1) begin

      mismatch_count++;

      `uvm_error("SCB_ADDRESS_MISMATCH",
        $sformatf(
          "[SCB_MISMATCH] Endereco inesperado\n\
           Recebido : 0x%03h",
          item.addr
        ))

      return;

    end


    // Armazena a palavra recebida na posicao correspondente
    case (item.addr)

      10'd0: begin
        dut_block[127:96] = item.rdata;
        dut_word_valid[0] = 1'b1;
      end

      10'd1: begin
        dut_block[95:64] = item.rdata;
        dut_word_valid[1] = 1'b1;
      end

      10'd2: begin
        dut_block[63:32] = item.rdata;
        dut_word_valid[2] = 1'b1;
      end

      10'd3: begin
        dut_block[31:0] = item.rdata;
        dut_word_valid[3] = 1'b1;
      end

      default: begin
      end

    endcase


    // Remove somente o resultado correspondente
    expected_words.delete(match_idx);
    expected_addresses.delete(match_idx);


    // Aguarda a leitura das quatro palavras do bloco
    if (dut_word_valid == 4'b1111) begin

      // Compara o bloco completo de 128 bits
      if (dut_block === expected_block) begin

        match_count++;

        `uvm_info("SCB_BLOCK_MATCH",
          $sformatf(
            "[SCB_BLOCK_MATCH] PASS | Bloco AES: DUT: %032h | REF: %032h",
            dut_block,
            expected_block
          ),
          UVM_LOW)

      end
      else begin

        mismatch_count++;

        `uvm_error("SCB_BLOCK_MISMATCH",
          $sformatf(
            "[SCB_BLOCK_MISMATCH] Divergencia no bloco AES de 128 bits\n\
             DUT      : %032h\n\
             Ref Model: %032h\n\
             Diferenca: %032h",
            dut_block,
            expected_block,
            dut_block ^ expected_block
          ))

      end


      // Prepara o controle para o proximo bloco
      dut_block = '0;
      dut_word_valid = '0;

    end

  endfunction : write_mem


  // Verifica a consistencia final do Scoreboard
  function void check_phase(uvm_phase phase);

    string result;

    super.check_phase(phase);


    // Verifica se o modelo de referencia foi executado
    if (refmodel_count == 0) begin

      `uvm_error("SCB_NO_REFMODEL",
        "O modelo de referencia C++ nao foi executado durante o teste")

    end


    // Verifica resultados esperados pendentes
    if (expected_words.size() != 0 ||
        expected_addresses.size() != 0) begin

      `uvm_error("SCB_PENDING_DATA",
        $sformatf(
          "Restam %0d palavras e %0d enderecos esperados que nao foram lidos do DUT",
          expected_words.size(),
          expected_addresses.size()
        ))

    end


    // Verifica se existe um bloco recebido parcialmente
    if (dut_word_valid != 4'b0000) begin

      `uvm_error("SCB_INCOMPLETE_BLOCK",
        $sformatf(
          "Bloco incompleto recebido do DUT | Mascara de validade: %04b | DUT: %032h",
          dut_word_valid,
          dut_block
        ))

    end


    // Determina o resultado final
    result = (
      refmodel_count > 0 &&
      match_count > 0 &&
      mismatch_count == 0 &&
      expected_words.size() == 0 &&
      expected_addresses.size() == 0 &&
      dut_word_valid == 4'b0000
    ) ? "PASS" : "FAIL";


    // Exibe o resumo da verificacao
    `uvm_info("SCB_SUMMARY",
      $sformatf(
        "\n========== RESUMO DO SCOREBOARD ==========\n\
         Modelo de referencia : %0d\n\
         Blocos aprovados    : %0d\n\
         Divergencias        : %0d\n\
         Palavras pendentes  : %0d\n\
         Enderecos pendentes : %0d\n\
         Bloco parcial       : %04b\n\
         Resultado           : %s\n\
         =========================================",
        refmodel_count,
        match_count,
        mismatch_count,
        expected_words.size(),
        expected_addresses.size(),
        dut_word_valid,
        result
      ),
      UVM_NONE)

  endfunction : check_phase


endclass : minisoc_scb
