class minisoc_subscriber extends uvm_subscriber #(mem_data_item);
  `uvm_component_utils(minisoc_subscriber)

  // Variaveis locais para amostragem no Covergroup
  bit [15:0] sampled_addr;
  bit        sampled_we;
  bit [2:0]  sampled_mode;
  bit        sampled_is_decrypt;

  // ---------------------------------------------------------------------------
  // Definicao dos Covergroups
  // ---------------------------------------------------------------------------
  covergroup cg_mem_access;
    option.per_instance = 1;
    option.comment      = "Cobertura de acessos ao barramento de memoria do AES";

    // Cobertura do tipo de operacao (Escrita / Leitura)
    cp_op: coverpoint sampled_we {
      bins read_op  = {1'b0};
      bins write_op = {1 me_b1};
    }

    // Cobertura do espaco de enderecamento do AES
    cp_addr: coverpoint sampled_addr {
      bins addr_key  = {16'hA000};
      bins addr_iv   = {16'hA010};
      bins addr_din  = {16'hA020};
      bins addr_dout = {16'hA030};
      bins addr_ctrl = {16'hA040};
      illegal_bins addr_invalid = default;
    }

    // Cobertura cruzada entre Endereco e Operacao (Ex: Garantir que DOUT teve Leitura e DIN teve Escrita)
    cross_op_addr: cross cp_op, cp_addr;
  endgroup : cg_mem_access

  covergroup cg_aes_config;
    option.per_instance = 1;
    option.comment      = "Cobertura de modos de operacao e direcao do AES";

    // Cobertura dos modos de operacao do algoritmo AES (conforme C++ Refmod)
    cp_mode: coverpoint sampled_mode {
      bins mode_ecb  = {3'd0};
      bins mode_cbc  = {3'd1};
      bins mode_pcbc = {3'd2};
      bins mode_cfb  = {3'd3};
      bins mode_ofb  = {3'd4};
      bins mode_ctr  = {3'd5};
    }

    // Cobertura da direcao (Cifragem vs Decifragem)
    cp_direction: coverpoint sampled_is_decrypt {
      bins encrypt = {1'b0};
      bins decrypt = {1'b1};
    }

    // Cross Coverage: Garantir que TODOS os modos foram testados tanto para ENCRYPT quanto para DECRYPT
    cross_mode_dir: cross cp_mode, cp_direction;
  endgroup : cg_aes_config

  // ---------------------------------------------------------------------------
  // Construtor & Phases
  // ---------------------------------------------------------------------------
  function new(string name = "minisoc_subscriber", uvm_component parent = null);
    super.new(name, parent);
    cg_mem_access = new();
    cg_aes_config = new();
  endfunction : new

  // Chamado automaticamente via uvm_analysis_port do Monitor
  function void write(mem_data_item t);
    sampled_addr = t.addr;
    sampled_we   = t.we;

    // Amostra o covergroup de acessos a memoria
    cg_mem_access.sample();

    // Se for escrita no registrador de controle (CTRL), extrai os bits de modo e direcao
    if (t.we && (t.addr == 16'hA040)) begin
      sampled_is_decrypt = t.wdata[0];
      sampled_mode       = t.wdata[3:1];
      
      // Amostra o covergroup de configuracao do AES
      cg_aes_config.sample();
    end
  endfunction : write

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("COV_REP", $sformatf("Functional Coverage Memory Access: %0.2f%%", cg_mem_access.get_inst_coverage()), UVM_NONE)
    `uvm_info("COV_REP", $sformatf("Functional Coverage AES Modes:     %0.2f%%", cg_aes_config.get_inst_coverage()), UVM_NONE)
  endfunction : report_phase

endclass : minisoc_subscriber