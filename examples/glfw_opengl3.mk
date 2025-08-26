GLFW_VER = 3.4
#
LIBS_DIR = ../../libc
GLFW_DIR = $(LIBS_DIR)/glfw/glfw-$(GLFW_VER).bin.WIN64

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
LIBS   += -L$(GLFW_DIR)/lib-mingw-w64

# GLFW static lib
ifeq ($(STATIC_GLFW),true)
    LIBS   += -lglfw3
else
# GLFW dll lib
    LIBS   += -lglfw3dll
endif
