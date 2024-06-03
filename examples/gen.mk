OPT += -o cimgui/cimgui
OPT += --imgui-include-dir $(IMGUI_ROOT)/

BIND_CMD = $(LIB_DIR)/dear_bindings/dear_bindings.py

.PHONY: gencimgui impl_opengl3 impl_glfw

gencimgui:
	@python $(BIND_CMD) $(OPT) $(IMGUI_ROOT)/imgui.h

OPT_BK += --imconfig-path $(IMGUI_ROOT)/imconfig.h

impl_opengl3: $(CIMGUI_ROOT)
	@python $(BIND_CMD) --backend $(OPT_BK) -o cimgui/cimgui_impl_opengl3 \
		                          $(IMGUI_ROOT)/backends/imgui_impl_opengl3.h
impl_glfw: $(CIMGUI_ROOT)
	@python $(BIND_CMD) --backend $(OPT_BK) -o cimgui/cimgui_impl_glfw \
		                          $(IMGUI_ROOT)/backends/imgui_impl_glfw.h
impl_sdl2: $(CIMGUI_ROOT)
	python $(BIND_CMD) --backend $(OPT_BK) -o cimgui/cimgui_impl_sdl2 \
		                          $(IMGUI_ROOT)/backends/imgui_impl_sdl2.h
impl_sdl3: $(CIMGUI_ROOT)
	python $(BIND_CMD) --backend $(OPT_BK) -o cimgui/cimgui_impl_sdl3 \
		                          $(IMGUI_ROOT)/backends/imgui_impl_sdl3.h
