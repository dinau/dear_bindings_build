TARGET = $(notdir $(CURDIR))

all:
	zig version
	zig build $(OPT)

run: all
	(cd zig-out/bin; ./$(TARGET).exe ; cp imgui.ini ../../)

clean:
	@-rm -fr zig-out
	@-rm -fr zig-cache .zig-cache

fmt:
	zig fmt .

cleanall:
