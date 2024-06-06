TARGET = $(notdir $(CURDIR))

# Link selection: true or false
#STATIC_CIMGUI = true
CFLAGS += -static

EXE = .exe

# TC : gcc or clang or zig
TC ?= gcc
ifeq ($(TC),gcc)
CC  = $(CCACHE) gcc
CXX = $(CCACHE) g++
CXXFLAGS += -Wno-stringop-overflow
endif
ifeq ($(TC),clang)
CC =  clang
CXX = clang++
endif
ifeq ($(TC),zig)
CC =  zig cc
CXX = zig c++
endif

LIB_DIR            = ../../libs
IMGUI_DIR          = $(LIB_DIR)/imgui
STB_DIR            = $(LIB_DIR)/stb
#
CIMGUI_DIR         = ../libs/cimgui
CIMGUI_BUILD_DIR   = $(CIMGUI_DIR)/.build
#
UTILS_DIR          = ../utils
FONT_HEADER_DIR    = $(UTILS_DIR)/fonticon
#
BUILD_DIR          = .build
OTHER_OBJ_DIR      = $(BUILD_DIR)/other
#
CIMGUI_ARCHIVE_DIR = ../libs
LIB_CIMGUI_ARCHIVE = $(CIMGUI_ARCHIVE_DIR)/libcimgui.a

#
VPATH = .:$(CIMGUI_DIR):$(IMGUI_DIR):$(IMGUI_DIR)/backends:$(UTILS_DIR)

# CImGui / ImGui sources
CIMGUI_SRCS_CPP += $(notdir $(wildcard $(CIMGUI_DIR)/*.cpp))
CIMGUI_SRCS_CPP += $(BACKEND_SRCS_CPP)
IMGUI_SRCS_CPP  += $(notdir $(wildcard $(IMGUI_DIR)/*.cpp))

# My sources
MY_SRCS_C   += $(wildcard *.c)
MY_SRCS_CPP += $(wildcard *.cpp)

# Utils sources
OTHER_SRCS_CPP += $(notdir $(wildcard $(UTILS_DIR)/*.cpp))
OTHER_SRCS_C   += $(notdir $(wildcard $(UTILS_DIR)/*.c))

CIMGUI_OBJS = $(addprefix $(CIMGUI_BUILD_DIR)/,$(CIMGUI_SRCS_CPP:.cpp=.o) $(IMGUI_SRCS_CPP:.cpp=.o))
OTHER_OBJS  = $(addprefix $(OTHER_OBJ_DIR)/,$(OTHER_SRCS_C:.c=.o) $(OTHER_SRCS_CPP:.cpp=.o))
MY_OBJS     = $(addprefix $(BUILD_DIR)/,$(MY_SRCS_C:.c=.o) $(MY_SRCS_CPP:.cpp=.o))

#
ifeq ($(STATIC_CIMGUI),true)
#CFLAGS += -static
else
#CFLAGS += -shared
endif
#
CFLAGS += -Wall
#CFLAGS +=  -Wextra
CFLAGS += -O2
ifeq ($(CC),gcc)
CFLAGS +=  -Wl,-s
CFLAGS += -ffunction-sections -fdata-sections -Wl,--gc-sections
else
STRIP = strip $(TARGET)$(EXE)
endif
#
CFLAGS += -I$(CIMGUI_DIR) -I$(IMGUI_DIR) -I. -I$(IMGUI_DIR)/backends
CFLAGS += -I$(UTILS_DIR)   -I$(FONT_HEADER_DIR)
CFLAGS += -I$(STB_DIR)

# CImGui flags
#CFLAGS += -DCIMGUI_IMPL_API="extern \"C\""
CFLAGS += -DCIMGUI_DEFINE_ENUMS_AND_STRUCTS
# ImGui flags
CFLAGS += -DIMGUI_DISABLE_OBSOLETE_FUNCTIONS=1
CFLAGS += -DImDrawIdx="unsigned int"
CFLAGS += -DIMGUI_ENABLE_WIN32_DEFAULT_IME_FUNCTIONS

# LIBS
LIBS += -lgdi32 -limm32 -lopengl32

DEPS_IMGUI  = $(wildcard $(IMGUI_DIR)/*.h)
DEPS_CIMGUI = $(CIMGUI_DIR)/cimgui.h
DEPS_OTHER  = $(wildcard *.h) $(wildcard $(UTILS_DIR)/*.h)
DEPS_PROJ   = $(wildcard *.h)

CXXFLAGS += $(CFLAGS)
CXXFLAGS += -fno-exceptions -fno-rtti -std=c++11
LDFLAGS += -L$(CIMGUI_ARCHIVE_DIR)

MAKE_DIRS = $(BUILD_DIR)        \
            $(CIMGUI_DIR)       \
 	          $(CIMGUI_BUILD_DIR) \
   	        $(OTHER_OBJ_DIR)

all: $(MAKE_DIRS) $(LIB_CIMGUI_ARCHIVE) $(TARGET)$(EXE) afterbuild
lib: $(LIB_CIMGUI_ARCHIVE)
afterbuild:
	-$(AFTER_BUILD)
#dll: $(BUILD_DIR) cimgui.dll

MAKE_DEPS += ../makefile.common.mk Makefile
$(TARGET)$(EXE): $(OTHER_OBJS) $(MY_OBJS) $(MAKE_DEPS)
	@echo [$(CXX)]: - Link - $@
	@$(CXX) $(CXXFLAGS) -o $@  $(OTHER_OBJS) $(MY_OBJS) -lcimgui $(LIBS) $(LDFLAGS)
	@-$(STRIP)

$(LIB_CIMGUI_ARCHIVE): $(CIMGUI_OBJS)
	@echo [$(AR) ]: $@
	@$(AR) -rc $@ $^

$(CIMGUI_BUILD_DIR)/%.o: %.cpp $(DEPS_IMGUI) $(MAKE_DEPS)
	@echo [$(CXX)]: $(notdir $<)
	@$(CXX) -c -o $@ $(CXXFLAGS) $<
#
$(CIMGUI_BUILD_DIR)/%.o: %.c $(DEPS_CIMGUI) $(MAKE_DEPS)
	@echo [$(CC)]: $(notdir $<)
	@$(CC) -c -o $@ $(CFLAGS) $<

$(OTHER_OBJ_DIR)/%.o: %.cpp $(DEPS_IMGUI) $(MAKE_DEPS)
	@echo [$(CXX)]: $(notdir $<)
	@$(CXX) -c -o $@ $(CXXFLAGS) $<
#
$(OTHER_OBJ_DIR)/%.o: %.c $(DEPS_CIMGUI) $(MAKE_DEPS)
	@echo [$(CC)]: $(notdir $<)
	@$(CC) -c -o $@ $(CFLAGS) $<

$(BUILD_DIR)/%.o: %.cpp $(DEPS_PROJ) $(MAKE_DEPS)
	@echo [$(CXX)]: $(notdir $<)
	@$(CXX) -c -o $@ $(CXXFLAGS) $<
#
$(BUILD_DIR)/%.o: %.c $(DEPS_PROJ) $(MAKE_DEPS)
	@echo [$(CC)]: $(notdir $<)
	@$(CC) -c -o $@ $(CFLAGS) $<
#
.PHONY: run gen clean cleanall cleanlib $(BUILD_DIR)

$(BUILD_DIR):
	@-mkdir -p  $@

$(CIMGUI_DIR):
	@-mkdir -p $@

$(CIMGUI_BUILD_DIR):
	@-mkdir -p $@

$(OTHER_OBJ_DIR):
	@-mkdir -p $@
#
run: all
	./$(TARGET)
#
clean:
	-rm $(TARGET)$(EXE)
	-rm $(TARGET).lib $(TARGET).pdb
	-rm $(MY_OBJS)
cleanlib:
	-rm $(LIB_CIMGUI_ARCHIVE)
	-rm -fr $(CIMGUI_BUILD_DIR)
cleanother:
	-rm -fr $(OTHER_OBJ_DIR)
cleanall: clean cleanlib cleanother
	-rm -fr $(BUILD_DIR)
#
include ../gen.mk
