# true:  Static link, use libSDL3.a
# false: Dynamic link, use SDL3.dll

#STATIC_SDL3 = true
HIDE_CONSOLE_WINDOW = true
DEBUG_INFO = false

include ../sdl3_opengl3.mk

LDFLAGS += -lkernel32 -luser32 -lgdi32 -lwinspool -lshell32 -lole32 -loleaut32
LDFLAGS += -luuid -lcomdlg32 -ladvapi32 -lsetupapi -lhid -lversion
LDFLAGS += -lws2_32 -ldinput8 -ldxguid -ldxerr8  -lwinmm

AFTER_BUILD = @cp -u $(SDL3_DIR)/bin/SDL3.dll .

include ../makefile.common.mk

gen: $(CIMGUI_DIR) gencimgui impl_opengl3 impl_sdl3
