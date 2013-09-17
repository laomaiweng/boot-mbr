TARGETS = hang halt hello 3fault reloc getchar disk
AS      = as -g
LDAS    = ld -s --oformat binary

.PHONY: all $(TARGETS) clean mrproper

all: $(TARGETS)

$(TARGETS):
	$(CC) -E $@.S > $@.s
	$(AS) -o $@.o $@.s
	$(LDAS) -Ttext 0x0000 -e 0x7c00 -o $@.mbr $@.o

clean:
	$(RM) $(TARGETS:%=%.s) $(TARGETS:%=%.o)

mrproper: clean
	$(RM) $(TARGETS:%=%.mbr)
