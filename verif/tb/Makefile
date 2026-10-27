include Makefile.files

.PHONY: all vcs_comp vcs_run vcs_verdi vcs_wave vcs_gui help clean

UVM_TEST ?= minisoc_rst_clk_test

all: vcs_comp vcs_run

vcs_comp:
	vcs $(VCS_FLAGS) $(VCS_CPP_FLAGS) $(VERDI_PLI) \
	$(VCS_INCDIRS) \
	$(TB_DIR)/refmod/cpp/aes_dpi_wrapper.cpp \
	$(TB_DIR)/refmod/cpp/aux_aes.cpp \
	$(MINISOC_TB_FILES) \
	-top tb_top \
	-l vcs_compile.log -o simv

vcs_run:
	./simv -cm line+cond+branch+tgl+fsm +UVM_TESTNAME=$(UVM_TEST) -l vcs_run.log

vcs_gui:
	./simv +UVM_TESTNAME=$(UVM_TEST) -gui &

vcs_verdi:
	verdi -ssf waves.fsdb &

vcs_wave:
	nWave -ssf waves.fsdb &

help:
	@echo '  make vcs_comp                  : Compila o projeto com o VCS'
	@echo '  make vcs_run [UVM_TEST=nome]   : Executa a simulacao via CLI'
	@echo '  make vcs_gui [UVM_TEST=nome]   : Executa a simulacao com a GUI'
	@echo '  make vcs_verdi                 : Abre o Verdi com a waveform'
	@echo '  make vcs_nwave                 : Abre apenas o nWave'
	@echo '  make clean                     : Remove arquivos temporarios'

clean:
	rm -rf csrc simv.daidir simv.cst simv.vdb *.log
	rm -rf simv ucli.key *.vpd *.vcd verdiLog *.fsdb novas.* vc_hdrs.h DVEfiles
	rm -rf nWaveLog vdCovLog
	rm -f .fsm.sch.verilog.xml vdCov.conf