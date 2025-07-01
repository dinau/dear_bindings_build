SDL2_DIR = ../../libs/sdl/SDL2/x86_64-w64-mingw32

# Add backend driver in imgui
BACKEND_SRCS_CPP += imgui_impl_opengl3.cpp
BACKEND_SRCS_CPP += imgui_impl_sdl2.cpp
BACKEND_SRCS_CPP += dcimgui_impl_opengl3.cpp
BACKEND_SRCS_CPP += dcimgui_impl_sdl2.cpp

#
CFLAGS += -DCIMGUI_USE_SDL2
CFLAGS += -DCIMGUI_USE_OPENGL3
LIBS   += -L.

# SDL2 settings
#CFLAGS += $(shell pkg-config --cflags sdl2)
CFLAGS += -I$(SDL2_DIR)/include
CFLAGS += -I$(SDL2_DIR)/include/SDL2
LIBS   += -L$(SDL2_DIR)/lib

# Use SDL2 Static lib
ifeq ($(STATIC_SDL2),true)
LIBS += -lSDL2
else
# Use SDL2 dll lib
LIBS += -lSDL2.dll

LDFLAGS += -mconsole -mwindows

endif
