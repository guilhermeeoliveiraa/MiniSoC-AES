class minisoc_rst_clk_test extends minisoc_base_test;
  `uvm_component_utils(minisoc_rst_clk_test)

  minisoc_clk_seq clk_seq;
  minisoc_rst_seq rst_seq;
  minisoc_spi_seq spi_seq;
  minisoc_mem_seq mem_seq;

  virtual clk_if clk_vif;
  virtual rst_if rst_vif;

  localparam realtime EXPECTED_PERIOD_NS = 0.5;
  localparam realtime PERIOD_TOLERANCE_NS = 0.01;
  localparam int RESET_TIMEOUT_CYCLES = 1000;

  bit clock_test_pass;
  bit initial_reset_pass;
  bit reset_during_operation_pass;
  bit reset_release_pass;

  function new(string name = "minisoc_rst_clk_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void configure_env(minisoc_env_config cfg);
    cfg.has_spi_agent = 1;
    cfg.has_mem_agent = 1;
    cfg.has_scoreboard = 1;
  endfunction : configure_env

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual clk_if)::get(
          this, "", "clk_vif", clk_vif)) begin
      `uvm_fatal("CLK_VIF", "Nao foi possivel obter clk_vif")
    end

    if (!uvm_config_db#(virtual rst_if)::get(
          this, "", "rst_vif", rst_vif)) begin
      `uvm_fatal("RST_VIF", "Nao foi possivel obter rst_vif")
    end
  endfunction : build_phase

  virtual task run_phase(uvm_phase phase);
    realtime t_rise_1;
    realtime t_rise_2;
    realtime measured_period;
    int cycles;

    phase.raise_objection(this);

    clock_test_pass = 1'b0;
    initial_reset_pass = 1'b0;
    reset_during_operation_pass = 1'b0;
    reset_release_pass = 1'b0;

    clk_seq = minisoc_clk_seq::type_id::create("clk_seq");
    rst_seq = minisoc_rst_seq::type_id::create("rst_seq");

    `uvm_info("CLOCK", "Verificando periodo do clock", UVM_NONE)

    clk_seq.start(env.clk_agent.sqr);

    @(posedge clk_vif.clk);
    t_rise_1 = $realtime;

    @(posedge clk_vif.clk);
    t_rise_2 = $realtime;

    measured_period = t_rise_2 - t_rise_1;

    if ((measured_period >= EXPECTED_PERIOD_NS - PERIOD_TOLERANCE_NS) &&
        (measured_period <= EXPECTED_PERIOD_NS + PERIOD_TOLERANCE_NS)) begin
      clock_test_pass = 1'b1;
      `uvm_info("CLOCK",
        $sformatf("PASS: periodo medido = %0.3f ns", measured_period),
        UVM_NONE)
    end
    else begin
      `uvm_error("CLOCK",
        $sformatf("FAIL: periodo medido = %0.3f ns; esperado = %0.3f ns",
                  measured_period, EXPECTED_PERIOD_NS))
    end

    `uvm_info("INITIAL_RESET", "Aplicando reset inicial", UVM_NONE)

    rst_seq.start(env.rst_agent.sqr);

    cycles = 0;
    while ((rst_vif.rst_n !== 1'b1) &&
           (cycles < RESET_TIMEOUT_CYCLES)) begin
      @(posedge rst_vif.clk);
      cycles++;
    end

    if (rst_vif.rst_n === 1'b1) begin
      initial_reset_pass = 1'b1;
      repeat (10) @(posedge rst_vif.clk);
      `uvm_info("INITIAL_RESET",
        "PASS: reset inicial liberado", UVM_NONE)
    end
    else begin
      `uvm_error("INITIAL_RESET",
        "FAIL: timeout aguardando a liberacao do reset")
    end

    if (initial_reset_pass) begin
      `uvm_info("SYSTEM_SETUP",
        "Preparando o sistema antes do segundo reset", UVM_NONE)

      spi_seq = minisoc_spi_seq::type_id::create("spi_init_pll_seq");
      spi_seq.operation = minisoc_spi_seq::SPI_SEQ_INIT_PLL;
      spi_seq.start(env.spi_agent.sqr);

      mem_seq = minisoc_mem_seq::type_id::create("mem_write_seq");
      mem_seq.operation = minisoc_mem_seq::MEM_WRITE_WORDS;
      mem_seq.start(env.mem_agent.sqr);

      spi_seq = minisoc_spi_seq::type_id::create("spi_config_aes_seq");
      spi_seq.operation = minisoc_spi_seq::SPI_SEQ_CONFIG_AES;
      spi_seq.start(env.spi_agent.sqr);

      spi_seq = minisoc_spi_seq::type_id::create("spi_give_mem_seq");
      spi_seq.operation = minisoc_spi_seq::SPI_SEQ_GIVE_MEM;
      spi_seq.start(env.spi_agent.sqr);

      spi_seq = minisoc_spi_seq::type_id::create("spi_start_aes_seq");
      spi_seq.operation = minisoc_spi_seq::SPI_SEQ_START_AES;
      spi_seq.start(env.spi_agent.sqr);

      `uvm_info("RESET_TEST",
        "Aplicando reset apos iniciar a operacao AES", UVM_NONE)

      fork
        begin
          rst_seq.start(env.rst_agent.sqr);
        end

        begin
          cycles = 0;

          while ((rst_vif.rst_n !== 1'b0) &&
                 (cycles < RESET_TIMEOUT_CYCLES)) begin
            @(negedge rst_vif.clk);
            cycles++;
          end

          if (rst_vif.rst_n === 1'b0) begin
            reset_during_operation_pass = 1'b1;
            `uvm_info("RESET_TEST",
              "PASS: reset externo foi ativado", UVM_NONE)
          end
          else begin
            `uvm_error("RESET_TEST",
              "FAIL: timeout aguardando a ativacao do reset")
          end

          cycles = 0;

          while ((rst_vif.rst_n !== 1'b1) &&
                 (cycles < RESET_TIMEOUT_CYCLES)) begin
            @(posedge rst_vif.clk);
            cycles++;
          end

          if (rst_vif.rst_n === 1'b1) begin
            reset_release_pass = 1'b1;
            repeat (10) @(posedge rst_vif.clk);
            `uvm_info("RESET_RELEASE",
              "PASS: reset externo foi liberado", UVM_NONE)
          end
          else begin
            `uvm_error("RESET_RELEASE",
              "FAIL: timeout aguardando a liberacao do reset")
          end
        end
      join
    end
    else begin
      `uvm_error("RESET_TEST",
        "Teste de reset durante a operacao nao executado")
    end

    `uvm_info("TEST_SUMMARY", "========== RESUMO DOS TESTES ==========", UVM_NONE)
    `uvm_info("TEST_SUMMARY",
      $sformatf("Clock: %s", clock_test_pass ? "PASS" : "FAIL"), UVM_NONE)
    `uvm_info("TEST_SUMMARY",
      $sformatf("Reset inicial: %s",
                initial_reset_pass ? "PASS" : "FAIL"), UVM_NONE)
    `uvm_info("TEST_SUMMARY",
      $sformatf("Aplicacao do segundo reset: %s",
                reset_during_operation_pass ? "PASS" : "FAIL"), UVM_NONE)
    `uvm_info("TEST_SUMMARY",
      $sformatf("Liberacao do segundo reset: %s",
                reset_release_pass ? "PASS" : "FAIL"), UVM_NONE)
    `uvm_info("TEST_SUMMARY", "=======================================", UVM_NONE)

    phase.drop_objection(this);
  endtask : run_phase

endclass : minisoc_rst_clk_test