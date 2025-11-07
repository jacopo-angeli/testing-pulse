
FSTAR_FILES := $(wildcard *.fst)
FSTAR_EXE := fstar.exe
EXTRACTED_DIR := extracted


all: verify

verify: $(FSTAR_FILES:.fst=.verified)

%.verified: %.fst
	$(FSTAR_EXE) $(basename $@).fst

.PHONY: all verify 