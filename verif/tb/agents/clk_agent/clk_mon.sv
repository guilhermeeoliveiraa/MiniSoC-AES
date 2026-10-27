`timescale 1ns/1ps

class clk_mon extends uvm_monitor;
  `uvm_component_utils(clk_mon)

  virtual clk_if vif;
  uvm_analysis_port #(clk_item) item_collected_port;

  realtime expected_period_ns = 0.5;
  realtime period_tolerance_ns = 0.1;
  time max_clk_loss_timeout = 100ns;

  function new(string name = "clk_mon", uvm_component parent = null);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (vif == null) begin
      if (!uvm_config_db#(virtual clk_if)::get(this, "", "clk_vif", vif))
        `uvm_fatal("CLK_MON_NO_VIF", "Virtual interface 'clk_vif' nao foi encontrada no uvm_config_db!")
    end
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    clk_item item;
    realtime t_pos1, t_neg, t_pos2;
    realtime period, high_time, low_time;
    realtime duty_cycle;
    realtime period_ns;

    fork
      begin
        forever begin
          @(posedge vif.clk);
          t_pos1 = $realtime;

          @(negedge vif.clk);
          t_neg = $realtime;

          @(posedge vif.clk);
          t_pos2 = $realtime;

          period = t_pos2 - t_pos1;
          high_time = t_neg - t_pos1;
          low_time = t_pos2 - t_neg;

          period_ns = period / 1ns;
          duty_cycle = (high_time / period) * 100.0;

          if ((period_ns < (expected_period_ns - period_tolerance_ns)) ||
              (period_ns > (expected_period_ns + period_tolerance_ns))) begin
            `uvm_error("CLK_PERIOD_VIOLATION",
              $sformatf("Periodo invalido! Esperado: %.3f ns, Detectado: %.3f ns, Tolerancia: %.3f ns",
                        expected_period_ns, period_ns, period_tolerance_ns))
          end

          item = clk_item::type_id::create("item");
          item.period_ps = period / 1ps;
          item.duty_cycle = duty_cycle;
          item.freq_mhz = 1000.0 / period_ns;

          item_collected_port.write(item);
        end
      end

      begin
        forever begin
          fork : clk_timeout_block
            begin
              @(posedge vif.clk);
            end
            begin
              #max_clk_loss_timeout;
              `uvm_error("CLK_LOSS",
                $sformatf("Clock travado ou inativo por mais de %0t!", max_clk_loss_timeout))
            end
          join_any
          disable clk_timeout_block;
        end
      end
    join
  endtask : run_phase
endclass : clk_mon