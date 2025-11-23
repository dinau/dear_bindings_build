# All example are built at a time.
EXAMPLE_DIRS =\
							examples/glfw_opengl3                \
	            examples/glfw_opengl3_image_load     \
	            examples/glfw_opengl3_image_save     \
	            examples/glfw_opengl3_jp

ifeq ($(OS),Windows_NT)
   EXAMPLE_DIRS	+= examples/sdl3_opengl3
endif


EXAMPLE_DIRS_ZIG =\
							examples/zig_glfw_opengl3            \
							examples/zig_glfw_opengl3_image_load \
							examples/zig_iconfontviewer          \
							examples/zig_imcolortextedit         \
							examples/zig_imfiledialog            \
							examples/zig_imguizmo                \
							examples/zig_imknobs                 \
							examples/zig_imnodes                 \
							examples/zig_implot                  \
							examples/zig_implot3d                \
              examples/zig_imPlotDemo              \
							examples/zig_imspinner               \
							examples/zig_imtoggle
ifeq ($(OS),Windows_NT)
   EXAMPLE_DIRS_ZIG	+= examples/zig_sdl3_opengl3
   EXAMPLE_DIRS_ZIG	+= examples/zig_sdl3_sdlgpu3
endif

.PHONY: test clean gen cc

all: zig cc

cc:
	$(foreach exdir,$(EXAMPLE_DIRS), $(call def_make,$(exdir),))

zig:
	$(foreach exdir,$(EXAMPLE_DIRS_ZIG), $(call def_make,$(exdir),cleancache))

fmt:
	$(foreach exdir,$(EXAMPLE_DIRS), $(call def_make,$(exdir),$@ ))


test:
	@echo $(notdir $(EXAMPLE_DIRS))

clean: cleanall

cleanall:
	@-$(foreach exdir,$(EXAMPLE_DIRS), $(call def_make,$(exdir),$@ ))
	@-$(foreach exdir,$(EXAMPLE_DIRS_ZIG), $(call def_make,$(exdir),$@ ))
	@-$(MAKE) -C src/libzig clean

DB_DIR             = ../dear_bindings
DCIMGUI_DIR        = src/libc/dcimgui
IMGUI_DIR          = src/libc/imgui
IMGUI_EXTERNAL_DIR = ../imgui

gen:
	@(cd $(DB_DIR); sh BuildAllBindings.sh)
	@rm -fr  $(DCIMGUI_DIR)
	@mkdir -p $(DCIMGUI_DIR)
	@cp -fr $(DB_DIR)/generated/* $(DCIMGUI_DIR)/
	@-mkdir -p $(IMGUI_DIR)
	@cp -fr $(IMGUI_EXTERNAL_DIR)/* $(IMGUI_DIR)/
	@echo
	@echo =====================================
	@echo OK: genereated: "$(DCIMGUI_DIR)/*"
	@echo =====================================

#
define def_make
	@echo ===============================
	@echo $(1)
	@echo ===============================
	@$(MAKE) -C  $(1) $(2)

endef

MAKEFLAGS += --no-print-directory
