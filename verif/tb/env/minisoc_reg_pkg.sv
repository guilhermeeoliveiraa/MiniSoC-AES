package minisoc_reg_pkg;

  // --------------------------------------------------
  // Enderecos dos registradores
  // --------------------------------------------------

  localparam logic [5:0] REG_KEY0           = 6'h00;
  localparam logic [5:0] REG_KEY1           = 6'h01;
  localparam logic [5:0] REG_KEY2           = 6'h02;
  localparam logic [5:0] REG_KEY3           = 6'h03;

  localparam logic [5:0] REG_IV0            = 6'h04;
  localparam logic [5:0] REG_IV1            = 6'h05;
  localparam logic [5:0] REG_IV2            = 6'h06;
  localparam logic [5:0] REG_IV3            = 6'h07;

  localparam logic [5:0] REG_COUNTER_HI     = 6'h08;
  localparam logic [5:0] REG_COUNTER_LO     = 6'h09;

  localparam logic [5:0] REG_NUM_BLOCKS     = 6'h0A;
  localparam logic [5:0] REG_AES_CONTROL    = 6'h0B;
  localparam logic [5:0] REG_AES_STATUS     = 6'h0C;

  localparam logic [5:0] REG_VERSION        = 6'h0D;
  localparam logic [5:0] REG_SYSTEM_CONTROL = 6'h0E;
  localparam logic [5:0] REG_SYSTEM_STATUS  = 6'h0F;

  localparam logic [5:0] REG_NOP            = 6'h3F;


  // --------------------------------------------------
  // Campos do AES_CONTROL
  // --------------------------------------------------

  localparam logic [31:0] AES_START_MASK   = 32'h00000001;
  localparam logic [31:0] AES_DECRYPT_MASK = 32'h00000002;
  localparam logic [31:0] AES_MODE_MASK    = 32'h0000001C;


  // --------------------------------------------------
  // Campos do AES_STATUS
  // --------------------------------------------------

  localparam logic [31:0] AES_BUSY_MASK        = 32'h00000001;
  localparam logic [31:0] AES_DONE_MASK        = 32'h00000002;
  localparam logic [31:0] AES_ERROR_MASK       = 32'h00000004;
  localparam logic [31:0] AES_BLOCKS_DONE_MASK = 32'h00000FF8;


  // --------------------------------------------------
  // Campos do SYSTEM_CONTROL
  // --------------------------------------------------

  localparam logic [31:0] MEM_SEL_AES_MASK  = 32'h00000001;
  localparam logic [31:0] PLL_ENABLE_MASK   = 32'h00000002;
  localparam logic [31:0] PLL_DIV_SEL_MASK  = 32'h0000000C;


  // --------------------------------------------------
  // Campos do SYSTEM_STATUS
  // --------------------------------------------------

  localparam logic [31:0] PLL_LOCKED_MASK = 32'h00000001;

endpackage : minisoc_reg_pkg
