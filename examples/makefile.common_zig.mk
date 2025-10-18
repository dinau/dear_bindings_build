TARGET = $(notdir $(CURDIR))

ifeq ($(OS),Windows_NT)
	EXE = .exe
endif

all:
	zig version
	zig build $(OPT)

run: all
	(cd zig-out/bin; ./$(TARGET)$(EXE); cp imgui.ini ../../; cp $(TARGET).ini ../../)
	$(AFTER_EXEC)

clean:
	@-rm -fr zig-out
	@-rm -fr zig-cache .zig-cache

cleancache: all
	@-rm -fr .zig-cache

cleanall: clean

fmt:
	zig fmt .
