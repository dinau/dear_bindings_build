# All example are built at a time.
EXAMPLE_DIRS :=\
							examples/glfw_opengl3                \
	            examples/glfw_opengl3_image_load     \
	            examples/glfw_opengl3_image_save     \
	            examples/glfw_opengl3_jp             \
	            examples/sdl2_opengl3                \
							examples/zig_glfw_opengl3            \
							examples/zig_glfw_opengl3_image_load \
							examples/zig_imfiledialog            \
							examples/zig_imknobs                 \
							examples/zig_imspinner               \
							examples/zig_imtoggle                \
							examples/zig_sdl2_opengl3            \

EXAMPLE_DIRS_C := \
							examples/glfw_opengl3 \
	            examples/glfw_opengl3_image_load \
	            examples/glfw_opengl3_image_save \
	            examples/glfw_opengl3_jp \
	            examples/sdl2_opengl3

ifdef ($(OS),Windows_NT)
   EXAMPLE_DIRS	+= examples/sdl3_opengl3                \
   EXAMPLE_DIRS	+= examples/zig_sdl3_opengl3
endif

all:
	$(foreach exdir,$(EXAMPLE_DIRS), $(call def_make,$(exdir),$@ ))

fmt:
	$(foreach exdir,$(EXAMPLE_DIRS), $(call def_make,$(exdir),$@ ))

.PHONY: test clean gen

test:
	@echo $(notdir $(EXAMPLE_DIRS))

clean:
	$(foreach exdir,$(EXAMPLE_DIRS), $(call def_make,$(exdir),$@ ))

DB_DIR             = ../dear_bindings
DCIMGUI_DIR        = libs/dcimgui
IMGUI_DIR          = libs/imgui
IMGUI_EXTERNAL_DIR = ../imgui

gen:
	@(cd $(DB_DIR); sh BuildAllBindings.sh)
	@rm -fr  $(DCIMGUI_DIR)
	@mkdir -p $(DCIMGUI_DIR)
	@cp -fr $(DB_DIR)/generated/* $(DCIMGUI_DIR)/
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
