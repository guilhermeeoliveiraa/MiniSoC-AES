class clk_mon extends uvm_monitor;

  `uvm_component_utils(clk_mon)

  // Interface virtual utilizada pelo Monitor
  virtual clk_if.mon_mp vif;

  // Porta de analise para publicar as transacoes observadas
  uvm_analysis_port #(clk_item) item_collected_port;

  // Timeout para deteccao de ausencia do clock
  time max_clk_loss_timeout = 100ns;


  // Construtor
  function new(string name = "clk_mon",
               uvm_component parent = null);

    super.new(name, parent);

    item_collected_port = new("item_collected_port", this);

  endfunction : new


  // Recupera a interface virtual configurada
  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if (!uvm_config_db#(virtual clk_if.mon_mp)::get(
          this, "", "vif", vif
        )) begin

      `uvm_fatal("CLK_MON",
                 "Interface virtual clk_if.mon_mp nao configurada!")

    end

  endfunction : build_phase


  // Observa o clock e publica o periodo medido
  task run_phase(uvm_phase phase);

    clk_item item;

    realtime last_posedge;
    realtime current_posedge;
    realtime period;

    bit first_edge;

    first_edge = 1'b1;

    fork

      // Monitora as bordas de subida do clock
      begin

        forever begin

          @(posedge vif.clk);

          current_posedge = $realtime;

          if (!first_edge) begin

            period = current_posedge - last_posedge;

            item = clk_item::type_id::create("item");

            item.enable = 1'b1;
            item.period_ps = period / 1ps;

            item_collected_port.write(item);

          end

          last_posedge = current_posedge;
          first_edge = 1'b0;

        end

      end

      // Detecta ausencia de atividade no clock
      begin

        forever begin

          fork : clk_timeout_block

            begin

              @(posedge vif.clk);

            end

            begin

              #max_clk_loss_timeout;

              `uvm_error("CLK_LOSS",
                         "Clock inativo por mais do que o tempo permitido!")

            end

          join_any

          disable clk_timeout_block;

        end

      end

    join

  endtask : run_phase

endclass : clk_mon
