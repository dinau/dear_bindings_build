TARGET = $(notdir $(CURDIR))
#
OPT += --release=fast
#OPT += --release=small
# Fail compilation
#OPT += --release=safe

all:
	zig version
	zig build $(OPT)

run: all
	(cd zig-out/bin; ./$(TARGET).exe)

cleanall:
	-rm -fr zig-out
	-rm -fr zig-cache .zig-cache
