# true:  Static link, use libSDL2.a
# false: Dynamic link, use SDL2.dll

STATIC_SDL2 = true
HIDE_CONSOLE_WINDOW = true
DEBUG_INFO = false

include ../sdl2_opengl3.mk

LDFLAGS += -lkernel32 -luser32 -lgdi32 -lwinspool -lshell32 -lole32 -loleaut32
LDFLAGS += -luuid -lcomdlg32 -ladvapi32 -lsetupapi -lhid -lversion
LDFLAGS += -lws2_32 -ldinput8 -ldxguid -ldxerr8  -lwinmm

include ../makefile.common.mk

gen: $(CIMGUI_DIR) gencimgui impl_opengl3 impl_sdl2
