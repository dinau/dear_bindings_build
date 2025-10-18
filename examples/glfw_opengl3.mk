GLFW_VER = 3.4
#
LIBS_DIR = ../../libc
ifeq ($(OS),Windows_NT)
	GLFW_DIR = $(LIBS_DIR)/glfw/glfw-$(GLFW_VER).bin.WIN64
else
	GLFW_DIR = /usr/lib/x86_64-linux-gnu
endif

# Add backend driver in imgui
BACKEND_SRCS_CPP += imgui_impl_opengl3.cpp
BACKEND_SRCS_CPP += imgui_impl_glfw.cpp
BACKEND_SRCS_CPP += dcimgui_impl_opengl3.cpp
BACKEND_SRCS_CPP += dcimgui_impl_glfw.cpp

#
CFLAGS += -DCIMGUI_USE_GLFW
CFLAGS += -DCIMGUI_USE_OPENGL3

# GLFW settings
#CFLAGS += $(shell pkg-config --cflags glfw3)
CFLAGS += -I$(GLFW_DIR)/include
LIBS   += -L.
ifeq ($(OS),Windows_NT)
	LIBS   += -L$(GLFW_DIR)/lib-mingw-w64
else
	LIBS   += -L$(GLFW_DIR)
endif

# GLFW static lib
ifeq ($(STATIC_GLFW),true)
    LIBS   += -lglfw3
else
# GLFW dll lib
	ifeq ($(OS),Windows_NT)
    LIBS   += -lglfw3dll
	endif
endif
