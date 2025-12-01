FSTAR_FILES := $(wildcard *.fst)
FSTAR_EXE := fstar.exe
EXTRACTED_DIR := extracted

CACHE_DIR 	:= .cache

FLAGS 		:=
FLAGS		+= --z3version 4.13.3
FLAGS 		+= --cache_checked_modules --cache_dir $(CACHE_DIR)
FLAGS 		+= --include $(PULSE_HOME)

%.fst-in %.fsti-in: FLAGS += --odir $(CACHE_DIR)
%.fst-in %.fsti-in:
	@echo $(FLAGS)

all: verify extract

verify: $(FSTAR_FILES:.fst=.verified)

extract: $(FSTAR_FILES:.fst=.extracted)

$(EXTRACTED_DIR):
	mkdir -p $(EXTRACTED_DIR)

%.verified: %.fst
	$(FSTAR_EXE) $(basename $@).fst $(FLAGS)

%.extracted: %.fst $(EXTRACTED_DIR)
	$(FSTAR_EXE) $(basename $@).fst $(FLAGS) --codegen Extension --odir ./$(EXTRACTED_DIR) \
	&& $(PULSE2RUST_EXE) $(EXTRACTED_DIR)/$(subst .,_,$(basename $@)).ast -odir ./$(EXTRACTED_DIR)

clean:
	rm -rf $(EXTRACTED_DIR)

rebuild: clean all

.PHONY: all verify extract clean rebuild
