FSTAR_FILES := $(wildcard *.fst)
FSTAR_EXE := fstar.exe
EXTRACTED_DIR := extracted

all: verify extract

verify: $(FSTAR_FILES:.fst=.verified)

extract: $(FSTAR_FILES:.fst=.extracted)

$(EXTRACTED_DIR):
	mkdir -p $(EXTRACTED_DIR)

%.verified: %.fst
	$(FSTAR_EXE) $(basename $@).fst --include $(PULSE_HOME)

%.extracted: %.fst $(EXTRACTED_DIR)
	$(FSTAR_EXE) $(basename $@).fst --include $(PULSE_HOME) --codegen Extension --odir ./$(EXTRACTED_DIR) \
	&& $(PULSE2RUST_EXE) $(EXTRACTED_DIR)/$(subst .,_,$(basename $@)).ast -odir ./$(EXTRACTED_DIR)

clean:
	rm -rf $(EXTRACTED_DIR)

rebuild: clean all

.PHONY: all verify extract clean rebuild