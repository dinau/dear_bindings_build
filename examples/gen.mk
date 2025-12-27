OPT += -o $(CIMGUI_DIR)/cimgui
OPT += --imgui-include-dir $(IMGUI_DIR)/

BIND_CMD = $(LIB_DIR)/dear_bindings/dear_bindings.py

.PHONY: gencimgui impl_opengl3 impl_glfw

gencimgui:
	python $(BIND_CMD) $(OPT) $(IMGUI_DIR)/imgui.h

OPT_BK += --imconfig-path $(IMGUI_DIR)/imconfig.h

impl_opengl3: $(CIMGUI_DIR)
	@python $(BIND_CMD) --backend $(OPT_BK) -o $(CIMGUI_DIR)/cimgui_impl_opengl3 \
		                          $(IMGUI_DIR)/backends/imgui_impl_opengl3.h
impl_glfw: $(CIMGUI_DIR)
	@python $(BIND_CMD) --backend $(OPT_BK) -o $(CIMGUI_DIR)/cimgui_impl_glfw \
		                          $(IMGUI_DIR)/backends/imgui_impl_glfw.h
impl_sdl2: $(CIMGUI_DIR)
	python $(BIND_CMD) --backend $(OPT_BK) -o $(CIMGUI_DIR)/cimgui_impl_sdl2 \
		                          $(IMGUI_DIR)/backends/imgui_impl_sdl2.h
impl_sdl3: $(CIMGUI_DIR)
	python $(BIND_CMD) --backend $(OPT_BK) -o $(CIMGUI_DIR)/cimgui_impl_sdl3 \
		                          $(IMGUI_DIR)/backends/imgui_impl_sdl3.h
