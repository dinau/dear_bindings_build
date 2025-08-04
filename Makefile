# All example are built at a time.
EXAMPLE_DIRS =\
							examples/zig_glfw_opengl3            \
							examples/zig_glfw_opengl3_image_load \
							examples/zig_iconfontviewer          \
							examples/zig_imfiledialog            \
							examples/zig_imknobs                 \
							examples/zig_imspinner               \
							examples/zig_imtoggle                \

ifeq ($(OS),Windows_NT)
   EXAMPLE_DIRS	+= examples/glfw_opengl3
   EXAMPLE_DIRS	+= examples/glfw_opengl3_image_load
   EXAMPLE_DIRS	+= examples/glfw_opengl3_image_save
   EXAMPLE_DIRS	+= examples/glfw_opengl3_jp
   EXAMPLE_DIRS	+= examples/sdl3_opengl3
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

cleanall:
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
