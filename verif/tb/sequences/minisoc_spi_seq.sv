class minisoc_spi_seq extends uvm_sequence #(spi_item);
  `uvm_object_utils(minisoc_spi_seq)

  typedef enum {
    SPI_SEQ_INIT_PLL,
    SPI_SEQ_CONFIG_AES,
    SPI_SEQ_GIVE_MEM,
    SPI_SEQ_START_AES,
    SPI_SEQ_WAIT_DONE,
    SPI_SEQ_RELEASE_MEM
  } spi_operation_e;

  spi_operation_e operation = SPI_SEQ_INIT_PLL;

  logic [127:0] aes_key = 128'h000102030405060708090A0B0C0D0E0F;
  logic [31:0] status;
  int unsigned poll_limit = 1000;

  function new(string name = "minisoc_spi_seq");
    super.new(name);
  endfunction

  task body();
    case (operation)
      SPI_SEQ_INIT_PLL: begin
        spi_write_reg(6'h0E, 32'h0000000E);

        for (int unsigned i = 0; i < poll_limit; i++) begin
          spi_read_reg(6'h0F, status);
          if (status[0])
            return;
          #100ns;
        end

        `uvm_fatal("PLL_TIMEOUT", "Timeout aguardando PLL_LOCKED")
      end

      SPI_SEQ_CONFIG_AES: begin
        spi_write_reg(6'h00, aes_key[127:96]);
        spi_write_reg(6'h01, aes_key[95:64]);
        spi_write_reg(6'h02, aes_key[63:32]);
        spi_write_reg(6'h03, aes_key[31:0]);
        spi_write_reg(6'h0A, 32'd1);
        spi_write_reg(6'h0B, 32'h00000000);
      end

      SPI_SEQ_GIVE_MEM: begin
        spi_write_reg(6'h0E, 32'h0000000F);
      end

      SPI_SEQ_START_AES: begin
        spi_write_reg(6'h0B, 32'h00000001);
      end

      SPI_SEQ_WAIT_DONE: begin
        for (int unsigned i = 0; i < poll_limit; i++) begin
          spi_read_reg(6'h0C, status);

          if (status[2])
            `uvm_fatal("AES_ERROR", $sformatf("AES informou ERROR. STATUS=0x%08h", status))

          if (status[1])
            return;

          #100ns;
        end

        `uvm_fatal("AES_TIMEOUT", "Timeout aguardando AES_DONE")
      end

      SPI_SEQ_RELEASE_MEM: begin
        spi_write_reg(6'h0E, 32'h0000000E);
      end

      default:
        `uvm_fatal("SPI_SEQ_OPERATION", "Operacao SPI desconhecida")
    endcase
  endtask

  task spi_write_reg(input logic [5:0] addr, input logic [31:0] data);
    spi_item req;

    req = spi_item::type_id::create("spi_write_req");
    start_item(req);
    req.op = spi_item::SPI_WRITE;
    req.addr = {2'b00, addr};
    req.data = data;
    req.rx_data = '0;
    finish_item(req);
  endtask

  task spi_read_reg(input logic [5:0] addr, output logic [31:0] data);
    spi_item req;

    req = spi_item::type_id::create("spi_read_req");
    start_item(req);
    req.op = spi_item::SPI_READ;
    req.addr = {2'b00, addr};
    req.data = '0;
    req.rx_data = '0;
    finish_item(req);
    data = req.rx_data;
  endtask
endclass : minisoc_spi_seq