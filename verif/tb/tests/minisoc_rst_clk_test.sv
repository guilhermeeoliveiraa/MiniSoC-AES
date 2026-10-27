class minisoc_rst_clk_test extends minisoc_base_test;
  `uvm_component_utils(minisoc_rst_clk_test)

  minisoc_clk_seq clk_seq;
  minisoc_rst_seq rst_seq;

  virtual clk_if clk_vif;
  virtual rst_if rst_vif;

  localparam realtime EXPECTED_PERIOD_NS = 0.5;
  localparam realtime PERIOD_TOLERANCE_NS = 0.01;

  bit t1_pass;
  bit t2_pass;
  bit t3_pass;

  function new(string name = "minisoc_rst_clk_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

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
    bit reset_asserted;
    bit reset_released;

    phase.raise_objection(this);

    t1_pass = 1'b0;
    t2_pass = 1'b0;
    t3_pass = 1'b0;

    clk_seq = minisoc_clk_seq::type_id::create("clk_seq");
    rst_seq = minisoc_rst_seq::type_id::create("rst_seq");

    `uvm_info("T1", "T1 - Clock: verificando periodo do clock", UVM_NONE)

    clk_seq.start(env.clk_agent.sqr);

    @(posedge clk_vif.clk);
    t_rise_1 = $realtime;

    @(posedge clk_vif.clk);
    t_rise_2 = $realtime;

    measured_period = t_rise_2 - t_rise_1;

    if ((measured_period >= EXPECTED_PERIOD_NS - PERIOD_TOLERANCE_NS) &&
        (measured_period <= EXPECTED_PERIOD_NS + PERIOD_TOLERANCE_NS)) begin
      t1_pass = 1'b1;
      `uvm_info("T1",
        $sformatf("PASS: periodo medido = %0.3f ns",
                  measured_period), UVM_NONE)
    end
    else begin
      `uvm_error("T1",
        $sformatf("FAIL: periodo medido = %0.3f ns; esperado = %0.3f ns",
                  measured_period, EXPECTED_PERIOD_NS))
    end

    `uvm_info("T2", "T2 - Reset global: verificando assercao", UVM_NONE)

    reset_asserted = 1'b0;
    reset_released = 1'b0;

    fork
      begin
        rst_seq.start(env.rst_agent.sqr);
      end

      begin
        wait (rst_vif.rst_n === 1'b0);
        reset_asserted = 1'b1;
        `uvm_info("T2", "Reset ativo: rst_n = 0", UVM_NONE)

        wait (rst_vif.rst_n === 1'b1);
        reset_released = 1'b1;
        `uvm_info("T3", "Reset liberado: rst_n = 1", UVM_NONE)
      end
    join

    if (reset_asserted) begin
      t2_pass = 1'b1;
      `uvm_info("T2", "PASS: reset foi aplicado", UVM_NONE)
    end
    else begin
      `uvm_error("T2", "FAIL: reset nao foi aplicado")
    end

    `uvm_info("T3", "T3 - Reset: verificando liberacao", UVM_NONE)

    if (reset_released && rst_vif.rst_n === 1'b1) begin
      t3_pass = 1'b1;
      `uvm_info("T3", "PASS: reset foi liberado", UVM_NONE)
    end
    else begin
      `uvm_error("T3", "FAIL: reset nao foi liberado corretamente")
    end

    `uvm_info("TEST_SUMMARY", "========== RESUMO DOS TESTES ==========", UVM_NONE)
    `uvm_info("TEST_SUMMARY",
      $sformatf("T1 - Clock: %s", t1_pass ? "PASS" : "FAIL"), UVM_NONE)
    `uvm_info("TEST_SUMMARY",
      $sformatf("T2 - Reset global: %s", t2_pass ? "PASS" : "FAIL"), UVM_NONE)
    `uvm_info("TEST_SUMMARY",
      $sformatf("T3 - Liberacao do reset: %s", t3_pass ? "PASS" : "FAIL"), UVM_NONE)
    `uvm_info("TEST_SUMMARY", "=======================================", UVM_NONE)

    phase.drop_objection(this);
  endtask : run_phase

endclass : minisoc_rst_clk_test