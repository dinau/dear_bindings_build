ifeq ($(OS),Windows_NT)
	STATIC_GLFW = true
endif
HIDE_CONSOLE_WINDOW = true
DEBUG_INFO = false

include ../glfw_opengl3.mk
include ../makefile.common.mk

gen: $(CIMGUI_DIR) gencimgui impl_opengl3 impl_glfw
