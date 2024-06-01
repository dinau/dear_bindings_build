OPT += -o cimgui
OPT += --imgui-include-dir $(IMGUI_ROOT)/

BIND_CMD = $(LIB_DIR)/dear_bindings/dear_bindings.py

.PHONY: gen bc
gen:
	python $(BIND_CMD) $(OPT) $(IMGUI_ROOT)/imgui.h

OPT_BK += --imconfig-path $(IMGUI_ROOT)/imconfig.h

bc:
	python $(BIND_CMD) --backend $(OPT_BK) -o cimgui_impl_opengl3 \
		          $(IMGUI_ROOT)/backends/imgui_impl_opengl3.h
	python $(BIND_CMD) --backend $(OPT_BK) -o cimgui_impl_glfw \
		          $(IMGUI_ROOT)/backends/imgui_impl_glfw.h
