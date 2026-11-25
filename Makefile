.PHONY: all vcs_comp vcs_run vcs_gui vcs_cov vcs_verdi vcs_wave help clean

# Teste UVM padrao
UVM_TEST ?= minisoc_random_test

# Diretorio da verificacao
TB_DIR := verif/tb

# Compilacao e simulacao
all: vcs_comp vcs_run

vcs_comp:
	$(MAKE) -C $(TB_DIR) vcs_comp

vcs_run:
	$(MAKE) -C $(TB_DIR) vcs_run UVM_TEST=$(UVM_TEST)

vcs_gui:
	$(MAKE) -C $(TB_DIR) vcs_gui UVM_TEST=$(UVM_TEST)

# Coverage
vcs_cov:
	$(MAKE) -C $(TB_DIR) vcs_cov

# Visualizacao das formas de onda
vcs_verdi:
	$(MAKE) -C $(TB_DIR) vcs_verdi

vcs_wave:
	$(MAKE) -C $(TB_DIR) vcs_wave

# Ajuda
help:
	@echo " make all                         : Compila e executa"
	@echo " make vcs_comp                    : Compila com VCS"
	@echo " make vcs_run                     : Executa simulacao"
	@echo " make vcs_run UVM_TEST=nome       : Executa teste especifico"
	@echo " make vcs_gui                     : Executa simulacao com GUI"
	@echo " make vcs_cov                     : Abre Coverage no Verdi"
	@echo " make vcs_verdi                   : Abre waveform no Verdi"
	@echo " make vcs_wave                    : Abre waveform no nWave"
	@echo " make clean                       : Limpa arquivos temporarios"


# Limpeza
clean:
	$(MAKE) -C $(TB_DIR) clean
