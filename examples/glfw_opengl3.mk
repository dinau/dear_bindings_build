STATIC_GLFW = true
GLFW_VER = 3.3.9
#
ifeq ($(PROCESSOR_ARCHITECTURE),x86)
  GLFW_DIR = $(LIB_DIR)/glfw/glfw-$(GLFW_VER).bin.WIN32
else
  GLFW_DIR = $(LIB_DIR)/glfw/glfw-$(GLFW_VER).bin.WIN64
endif

# Add backend driver in imgui
SRCS_CPP += imgui_impl_opengl3.cpp
SRCS_CPP += imgui_impl_glfw.cpp

#
CFLAGS += -DCIMGUI_USE_GLFW
CFLAGS += -DCIMGUI_USE_OPENGL3

# GLFW settings
#CFLAGS += $(shell pkg-config --cflags glfw3)
CFLAGS += -I$(GLFW_DIR)/include
LIBS   += -L.
LIBS   += -L$(GLFW_DIR)/lib-mingw-w64

# GLFW Static lib
ifeq ($(STATIC_GLFW),true)
LIBS += -lglfw3
else
# GLFW dll lib
LIBS += -lglfw3dll

MAKE_DEPS += ../glfw_opengl3.mk

endif
