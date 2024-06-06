SDL3_VER = 2024-06-02
#
SDL3_DIR = $(LIB_DIR)/sdl/sdl3/$(ARC)/SDL3-$(SDL3_VER)/SDL3

# Add backend driver in imgui
BACKEND_SRCS_CPP += imgui_impl_opengl3.cpp
BACKEND_SRCS_CPP += imgui_impl_sdl3.cpp

#
CFLAGS += -DCIMGUI_USE_SDL3
CFLAGS += -DCIMGUI_USE_OPENGL3
LIBS   += -L.

# SDL3 settings
#CFLAGS += $(shell pkg-config --cflags sdl3)
CFLAGS += -I$(SDL3_DIR)/include
LIBS   += -L$(SDL3_DIR)/lib

# Use SDL3 Static lib
ifeq ($(STATIC_SDL3),true)
LIBS += -lSDL3
else
# Use SDL3 dll lib
#LIBS += -lSDL3.dll
LIBS += -lSDL3

LDFLAGS += -mconsole -mwindows

MAKE_DEPS += ../sdl3_opengl3.mk

endif
