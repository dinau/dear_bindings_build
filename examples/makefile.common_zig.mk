TARGET = $(notdir $(CURDIR))

ifeq ($(OS),Windows_NT)
	EXE = .exe
endif

all:
	zig version
	zig build $(OPT)

ZIG_BIN_DIR = zig-out/bin

run: all
	(cd $(ZIG_BIN_DIR); $(LOCAL_LIB_PATH) ./$(TARGET)$(EXE))
ifneq ($(COPY_IMGUI_INI),false)
	@-cp $(ZIG_BIN_DIR)/imgui.ini .
endif
	$(AFTER_EXEC)

clean:
	@-rm -fr zig-out .zig-cache

cleancache: all
	@-rm -fr .zig-cache

cleanall: clean

fmt:
	zig fmt .
