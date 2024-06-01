TARGET = $(notdir $(CURDIR))

# Link selection: true or false
STATIC_CIMGUI = true
STATIC_GLFW = true
GLFW_VER = 3.3.9

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

ifeq ($(PROCESSOR_ARCHITECTURE),x86)
  GLFW_DIR = $(LIB_DIR)/glfw/glfw-$(GLFW_VER).bin.WIN32
else
  GLFW_DIR = $(LIB_DIR)/glfw/glfw-$(GLFW_VER).bin.WIN64
endif

IMGUI_ROOT = $(LIB_DIR)/imgui
CIMGUI_ROOT = cimgui
VPATH = .;$(CIMGUI_ROOT);$(IMGUI_ROOT);$(IMGUI_ROOT)/backends
# cpp sources
# cpp sources current folder
SRCS_CPP += $(wildcard *.cpp)
# CImGui / ImGui sources
SRCS_CPP += $(notdir $(wildcard $(CIMGUI_ROOT)/*.cpp))
SRCS_CPP += $(notdir $(wildcard $(IMGUI_ROOT)/*.cpp))
# c sources current folder
SRCS_C   += $(wildcard *.c)

# Add backend driver in imgui
SRCS_CPP += imgui_impl_opengl3.cpp
SRCS_CPP += imgui_impl_glfw.cpp
OBJS = $(addprefix $(BUILD_DIR)/, $(SRCS_C:.c=.o) $(SRCS_CPP:.cpp=.o))
OBJSA := $(filter-out $(BUILD_DIR)/$(TARGET).o, $(OBJS))
#
ifeq ($(STATIC_CIMGUI),true)
CFLAGS += -static
else
CFLAGS += -shared
endif
CFLAGS += -O2
ifeq ($(CC),gcc)
CFLAGS +=  -Wl,-s
CFLAGS += -ffunction-sections -fdata-sections -Wl,--gc-sections
else
STRIP = strip $(TARGET)$(EXE)
endif
CFLAGS += -I$(CIMGUI_ROOT) -I$(IMGUI_ROOT) -I. -I$(IMGUI_ROOT)/backends
# CImGui flags
#CFLAGS += -DCIMGUI_IMPL_API="extern \"C\""
CFLAGS += -DCIMGUI_USE_GLFW
CFLAGS += -DCIMGUI_USE_OPENGL3
CFLAGS += -DCIMGUI_DEFINE_ENUMS_AND_STRUCTS
# ImGui flags
CFLAGS += -DIMGUI_DISABLE_OBSOLETE_FUNCTIONS=1
CFLAGS += -DImDrawIdx="unsigned int"
CFLAGS += -DIMGUI_ENABLE_WIN32_DEFAULT_IME_FUNCTIONS

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
endif

# LIBS
LIBS += -lgdi32 -limm32 -lopengl32

DEPS_IMGUI = $(wildcard $(IMGUI_ROOT)/*.h)
DEPS_CIMGUI = $(CIMGUI_ROOT)/cimgui.h

CXXFLAGS += $(CFLAGS)
CXXFLAGS += -fno-exceptions -fno-rtti

all: $(BUILD_DIR) $(TARGET)$(EXE)
lib: libcimgui.a
#dll: $(BUILD_DIR) cimgui.dll

$(TARGET)$(EXE): libcimgui.a $(BUILD_DIR)/$(TARGET).o Makefile
	@$(CXX) $(CXXFLAGS) -o $@ $(BUILD_DIR)/$(TARGET).o -lcimgui $(LIBS)
	@-$(STRIP)

libcimgui.a: $(OBJSA)
	echo $(AR): $@
	@$(AR) -rc $@ $^

$(BUILD_DIR)/%.o: %.cpp $(DEPS_IMGUI)
	@echo $(CXX): $(notdir $<)
	@$(CXX) -c -o $@ $(CXXFLAGS) $<
#
$(BUILD_DIR)/%.o: %.c $(DEPS_CIMGUI)
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
gen: $(CIMGUI_ROOT) gencimgui impl_opengl3 impl_glfw
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
