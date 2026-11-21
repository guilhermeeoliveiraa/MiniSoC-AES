`uvm_analysis_imp_decl(_cov_mem)
`uvm_analysis_imp_decl(_cov_spi)


class minisoc_sub extends uvm_component;

  `uvm_component_utils(minisoc_sub)


  // Portas de analise dos monitores
  uvm_analysis_imp_cov_mem #(mem_data_item, minisoc_sub) mem_export;
  uvm_analysis_imp_cov_spi #(spi_item, minisoc_sub) spi_export;


  // Variaveis de cobertura de memoria
  bit [9:0] sampled_addr;
  bit       sampled_we;


  // Variaveis de cobertura SPI
  bit [5:0] sampled_spi_addr;
  bit       sampled_spi_op;


  // Variaveis de cobertura AES
  bit [2:0] sampled_mode;
  bit       sampled_is_decrypt;
  bit       sampled_mem_sel_aes;


  // Contadores de amostragem
  int unsigned mem_sample_count;
  int unsigned spi_sample_count;
  int unsigned aes_config_sample_count;


  // Cobertura de acessos a memoria
  covergroup cg_mem_access;

    option.per_instance = 1;

    cp_operation: coverpoint sampled_we {

      bins read  = {1'b0};
      bins write = {1'b1};

    }

    cp_address: coverpoint sampled_addr {

      bins block_word_0 = {10'd0};
      bins block_word_1 = {10'd1};
      bins block_word_2 = {10'd2};
      bins block_word_3 = {10'd3};

      bins remaining_memory = {[10'd4:10'd1023]};

    }

    cross_operation_address: cross cp_operation, cp_address;

  endgroup : cg_mem_access


  // Cobertura de transacoes SPI
  covergroup cg_spi_access;

    option.per_instance = 1;

    cp_operation: coverpoint sampled_spi_op {

      bins write = {1'b0};
      bins read  = {1'b1};

    }

    cp_address: coverpoint sampled_spi_addr {

      bins key_registers = {[6'h00:6'h03]};
      bins iv_registers = {[6'h04:6'h07]};
      bins counter_registers = {[6'h08:6'h09]};
      bins num_blocks = {6'h0A};
      bins aes_control = {6'h0B};
      bins aes_status = {6'h0C};
      bins version = {6'h0D};
      bins system_control = {6'h0E};
      bins system_status = {6'h0F};
      bins nop = {6'h3F};
      bins reserved = default;

    }

    cross_operation_address: cross cp_operation, cp_address;

  endgroup : cg_spi_access


  // Cobertura das configuracoes AES
  covergroup cg_aes_config;

    option.per_instance = 1;

    cp_mode: coverpoint sampled_mode {

      bins ecb  = {3'd0};
      bins cbc  = {3'd1};
      bins pcbc = {3'd2};
      bins cfb  = {3'd3};
      bins ofb  = {3'd4};
      bins ctr  = {3'd5};

      illegal_bins reserved = {3'd6, 3'd7};

    }

    cp_direction: coverpoint sampled_is_decrypt {

      bins encrypt = {1'b0};
      bins decrypt = {1'b1};

    }

    cross_mode_direction: cross cp_mode, cp_direction;

  endgroup : cg_aes_config


  // Construtor
  function new(string name = "minisoc_sub",
               uvm_component parent = null);

    super.new(name, parent);

    mem_export = new("mem_export", this);
    spi_export = new("spi_export", this);

    sampled_addr = '0;
    sampled_we = 1'b0;

    sampled_spi_addr = '0;
    sampled_spi_op = 1'b0;

    sampled_mode = '0;
    sampled_is_decrypt = 1'b0;
    sampled_mem_sel_aes = 1'b0;

    mem_sample_count = 0;
    spi_sample_count = 0;
    aes_config_sample_count = 0;

    cg_mem_access = new();
    cg_spi_access = new();
    cg_aes_config = new();

  endfunction : new


  // Recebe transacoes do monitor de memoria
  function void write_cov_mem(mem_data_item item);

    if (!item.en)
      return;

    sampled_addr = item.addr;
    sampled_we = item.we;

    cg_mem_access.sample();

    mem_sample_count++;

  endfunction : write_cov_mem


  // Recebe transacoes do monitor SPI
  function void write_cov_spi(spi_item item);

    if (item.op != spi_item::SPI_WRITE)
      sampled_spi_op = 1'b1;
    else
      sampled_spi_op = 1'b0;

    sampled_spi_addr = item.addr;

    cg_spi_access.sample();

    spi_sample_count++;


    // Atualiza informacoes de controle do MiniSoC
    if (item.op != spi_item::SPI_WRITE)
      return;

    case (item.addr)

      // SYSTEM_CONTROL
      6'h0E: begin

        sampled_mem_sel_aes = item.data[0];

      end

      // AES_CONTROL
      6'h0B: begin

        // Ignora comando START
        if (item.data[0])
          return;

        sampled_is_decrypt = item.data[1];
        sampled_mode = item.data[4:2];

        if (sampled_mode inside {[3'd0:3'd5]}) begin

          cg_aes_config.sample();

          aes_config_sample_count++;

        end

      end

      default: begin
      end

    endcase

  endfunction : write_cov_spi


  // Relatorio final de cobertura
  function void report_phase(uvm_phase phase);

    super.report_phase(phase);

    `uvm_info("MINISOC_COV",
      $sformatf(
        "Memory Coverage: %.2f%% | Samples: %0d",
        cg_mem_access.get_inst_coverage(),
        mem_sample_count
      ),
      UVM_NONE
    )

    `uvm_info("MINISOC_COV",
      $sformatf(
        "SPI Coverage: %.2f%% | Samples: %0d",
        cg_spi_access.get_inst_coverage(),
        spi_sample_count
      ),
      UVM_NONE
    )

    `uvm_info("MINISOC_COV",
      $sformatf(
        "AES Configuration Coverage: %.2f%% | Samples: %0d",
        cg_aes_config.get_inst_coverage(),
        aes_config_sample_count
      ),
      UVM_NONE
    )

  endfunction : report_phase


endclass : minisoc_sub
