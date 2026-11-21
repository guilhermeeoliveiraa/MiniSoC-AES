
class clk_drv extends uvm_driver #(clk_item);

  `uvm_component_utils(clk_drv)

  // Interface virtual utilizada pelo Driver
  virtual clk_if.drv_mp vif;

  // Periodo do clock
  realtime clk_period;

  // Estado de habilitacao do clock
  bit clk_enable;


  // Construtor
  function new(string name = "clk_drv",
               uvm_component parent = null);

    super.new(name, parent);

    clk_period = 500ps;
    clk_enable = 1'b0;

  endfunction : new


  // Recupera a interface virtual configurada
  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if (!uvm_config_db#(virtual clk_if.drv_mp)::get(
          this, "", "clk_vif", vif
        )) begin

      `uvm_fatal("CLK_DRV",
                 "Interface virtual clk_if.drv_mp nao configurada!")

    end

  endfunction : build_phase


  // Inicializa os sinais e executa as tarefas do Driver
  task run_phase(uvm_phase phase);

    // Inicializa o clock em nivel baixo
    vif.clk = 1'b0;

    fork

      // Recebe configuracoes do Sequencer
      begin

        forever begin

          // Aguarda um item do Sequencer
          seq_item_port.get_next_item(req);

          // Atualiza os parametros do clock
          drive_item(req);

          // Finaliza o item recebido
          seq_item_port.item_done();

        end

      end

      // Gera continuamente o clock
      begin

        clock_generation();

      end

    join

  endtask : run_phase


  // Atualiza os parametros de geracao do clock
  local task drive_item(clk_item item);

    if (item.period_ps > 0)
      clk_period = item.period_ps * 1ps;

    clk_enable = item.enable;

    if (!clk_enable)
      vif.clk = 1'b0;

  endtask : drive_item


  // Gera continuamente o clock enquanto estiver habilitado
  local task clock_generation();

    forever begin

      if (clk_enable) begin

        #(clk_period / 2);
        vif.clk = ~vif.clk;

      end
      else begin

        vif.clk = 1'b0;
        #1ns;

      end

    end

  endtask : clock_generation

endclass : clk_drv
