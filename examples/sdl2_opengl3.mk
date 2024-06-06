SDL2_VER = 2.30.3
#
ifeq ($(PROCESSOR_ARCHITECTURE),x86)
	ARC = i686
else
  ARC = x86_64
endif
SDL2_DIR = $(LIB_DIR)/sdl/SDL2-$(SDL2_VER)/$(ARC)-w64-mingw32

# Add backend driver in imgui
BACKEND_SRCS_CPP += imgui_impl_opengl3.cpp
BACKEND_SRCS_CPP += imgui_impl_sdl2.cpp

#
CFLAGS += -DCIMGUI_USE_SDL2
CFLAGS += -DCIMGUI_USE_OPENGL3
LIBS   += -L.

# SDL2 settings
#CFLAGS += $(shell pkg-config --cflags sdl2)
CFLAGS += -I$(SDL2_DIR)/include/SDL2
LIBS   += -L$(SDL2_DIR)/lib

# Use SDL2 Static lib
ifeq ($(STATIC_SDL2),true)
LIBS += -lSDL2
else
# Use SDL2 dll lib
LIBS += -lSDL2.dll

LDFLAGS += -mconsole -mwindows

MAKE_DEPS += ../sdl2_opengl3.mk

endif
