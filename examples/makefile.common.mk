TARGET = $(notdir $(CURDIR))

# Link selection: true or false
#STATIC_CIMGUI = true
CFLAGS += -static

EXE = .exe
BUILD_DIR = .build
LIB_DIR = ../../libs

# TC : gcc or clang or zig
TC ?= gcc
ifeq ($(TC),gcc)
CC = gcc
CXX = g++
CXXFLAGS += -Wno-stringop-overflow
endif
ifeq ($(TC),clang)
CC = clang
CXX = clang++
endif
ifeq ($(TC),zig)
CC = zig cc
CXX = zig c++
endif

IMGUI_ROOT  = $(LIB_DIR)/imgui
CIMGUI_ROOT = cimgui
UTILS_DIR   = ../utils
FONT_HEADER_DIR = $(UTILS_DIR)/fonticon

#
VPATH = .:$(CIMGUI_ROOT):$(IMGUI_ROOT):$(IMGUI_ROOT)/backends:$(UTILS_DIR)
# cpp sources
SRCS_CPP += $(wildcard *.cpp)
SRCS_CPP += $(notdir $(wildcard $(UTILS_DIR)/*.cpp))
# CImGui / ImGui sources
SRCS_CPP += $(notdir $(wildcard $(CIMGUI_ROOT)/*.cpp))
SRCS_CPP += $(notdir $(wildcard $(IMGUI_ROOT)/*.cpp))
# c sources
SRCS_C   += $(wildcard *.c)
SRCS_C   += $(notdir $(wildcard $(UTILS_DIR)/*.c))

OBJS = $(addprefix $(BUILD_DIR)/, $(SRCS_C:.c=.o) $(SRCS_CPP:.cpp=.o))
OBJSA := $(filter-out $(BUILD_DIR)/$(TARGET).o, $(OBJS))
#
ifeq ($(STATIC_CIMGUI),true)
#CFLAGS += -static
else
#CFLAGS += -shared
endif
#
CFLAGS += -O2
ifeq ($(CC),gcc)
CFLAGS +=  -Wl,-s
CFLAGS += -ffunction-sections -fdata-sections -Wl,--gc-sections
else
STRIP = strip $(TARGET)$(EXE)
endif
#
CFLAGS += -I$(CIMGUI_ROOT) -I$(IMGUI_ROOT) -I. -I$(IMGUI_ROOT)/backends
CFLAGS += -I$(UTILS_DIR)   -I$(FONT_HEADER_DIR)
# CImGui flags
#CFLAGS += -DCIMGUI_IMPL_API="extern \"C\""
CFLAGS += -DCIMGUI_DEFINE_ENUMS_AND_STRUCTS
# ImGui flags
CFLAGS += -DIMGUI_DISABLE_OBSOLETE_FUNCTIONS=1
CFLAGS += -DImDrawIdx="unsigned int"
CFLAGS += -DIMGUI_ENABLE_WIN32_DEFAULT_IME_FUNCTIONS

# LIBS
LIBS += -lgdi32 -limm32 -lopengl32

DEPS_IMGUI = $(wildcard $(IMGUI_ROOT)/*.h)
DEPS_CIMGUI = $(CIMGUI_ROOT)/cimgui.h

CXXFLAGS += $(CFLAGS)
CXXFLAGS += -fno-exceptions -fno-rtti

all: $(BUILD_DIR) $(TARGET)$(EXE) afterbuild
lib: libcimgui.a
afterbuild:
	-$(AFTER_BUILD)
#dll: $(BUILD_DIR) cimgui.dll

MAKE_DEPS += ../makefile.common.mk Makefile
$(TARGET)$(EXE): libcimgui.a $(BUILD_DIR)/$(TARGET).o $(MAKE_DEPS)
	@$(CXX) $(CXXFLAGS) -o $@ $(BUILD_DIR)/$(TARGET).o -lcimgui $(LIBS) $(LDFLAGS)
	@-$(STRIP)

libcimgui.a: $(OBJSA) $(MAKE_DEPS)
	@echo $(AR) : $@
	@$(AR) -rc $@ $^

$(BUILD_DIR)/%.o: %.cpp $(DEPS_IMGUI) $(MAKE_DEPS)
	@echo $(CXX): $(notdir $<)
	@$(CXX) -c -o $@ $(CXXFLAGS) $<
#
$(BUILD_DIR)/%.o: %.c $(DEPS_CIMGUI) $(MAKE_DEPS)
	@echo $(CC) : $(notdir $<)
	@$(CC) -c -o $@ $(CFLAGS) $<
#
.PHONY: run gen clean cleanall cleanlib

$(BUILD_DIR):
	@-mkdir $@

$(CIMGUI_ROOT):
	@-mkdir $@
#
run: all
	./$(TARGET)
#
#
clean:
	-rm $(TARGET)$(EXE)
	-rm $(TARGET).lib $(TARGET).pdb
	-rm $(BUILD_DIR)/$(TARGET).o
cleanlib:
	-rm libcimgui.a
	-rm -fr $(BUILD_DIR)
cleanall: clean cleanlib
	-rm -fr $(CIMGUI_ROOT)
#
include ../gen.mk
