FSTAR_FILES := $(wildcard *.fst)
FSTAR_EXE := fstar.exe
PULSE := ../../pulse/lib/pulse

all: verify

verify: $(FSTAR_FILES:.fst=.verified)

%.verified: %.fst
	$(FSTAR_EXE) $(basename $@).fst --include $(PULSE)

.PHONY: all verify
