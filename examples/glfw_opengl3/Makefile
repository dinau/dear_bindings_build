TARGET = $(notdir $(CURDIR))

# Link selection: true or false
STATIC_GLFW = true
GLFW_VER = 3.3.9

EXE = .exe
BUILD_DIR = .build
LIB_DIR = ../../libs

CC = gcc
ifeq ($(CC),gcc)
CC = gcc
CXX = g++
endif
ifeq ($(CC),clang)
CC = clang
CXX = clang++
endif
ifeq ($(CC),zig)
CC = zig cc
CXX = zig c++
endif

ifeq ($(PROCESSOR_ARCHITECTURE),x86)
  GLFW_DIR = $(LIB_DIR)/glfw-$(GLFW_VER).bin.WIN32
else
  GLFW_DIR = $(LIB_DIR)/glfw-$(GLFW_VER).bin.WIN64
endif

IMGUI_ROOT = $(LIB_DIR)/imgui
CIMGUI_ROOT = .
VPATH = .:$(IMGUI_ROOT):$(IMGUI_ROOT)/backends
SRCS += $(wildcard *.cpp)
SRCS += $(notdir $(wildcard $(IMGUI_ROOT)/*.cpp))

# Add backend driver
SRCS += imgui_impl_opengl3.cpp
SRCS += imgui_impl_glfw.cpp
OBJS = $(addprefix $(BUILD_DIR)/, $(TARGET).o $(SRCS:.cpp=.o))
#
CFLAGS += -O2
CFLAGS += -static
ifeq ($(CC),gcc)
CFLAGS +=  -Wl,-s
CFLAGS += -ffunction-sections -fdata-sections -Wl,--gc-sections
else
STRIP = strip $(TARGET)$(EXE)
endif
CFLAGS += -I$(IMGUI_ROOT) -I. -I$(IMGUI_ROOT)/backends
#CFLAGS += -DCIMGUI_IMPL_API="extern \"C\""
CFLAGS += -DCIMGUI_DEFINE_ENUMS_AND_STRUCTS
CFLAGS += -DIMGUI_DISABLE_OBSOLETE_FUNCTIONS=1
CFLAGS += -DCIMGUI_USE_GLFW
CFLAGS += -DCIMGUI_USE_OPENGL3
CFLAGS += -DImDrawIdx="unsigned int"
CFLAGS += -DIMGUI_ENABLE_WIN32_DEFAULT_IME_FUNCTIONS

# GLFW settings
#CFLAGS += $(shell pkg-config --cflags glfw3)
CFLAGS += -I$(GLFW_DIR)/include
LIBS+= -L$(GLFW_DIR)/lib-mingw-w64
#LIBS += -L$(GLFW_DIR)/lib-mingw
# Static lib
ifeq ($(STATIC_GLFW),true)
LIBS += -lglfw3
else
# Dll lib
LIBS += -lglfw3dll
endif

# LIBS
LIBS += -lgdi32 -limm32 -lopengl32

DEPS_IMGUI = $(wildcard $(IMGUI_ROOT)/*.h)
DEPS_CIMGUI = $(CIMGUI_ROOT)/cimgui.h

CXXFLAGS := $(CFLAGS)

.PHONY: run genbind clean

all: $(BUILD_DIR) $(TARGET)$(EXE)

$(BUILD_DIR)/%.o: %.cpp $(DEPS_IMGUI)
	@echo $(CXX): $(notdir $<)
	@$(CXX) -c -o $@ $(CXXFLAGS) $<
#
$(BUILD_DIR)/%.o: %.c $(DEPS_CIMGUI)
	@echo $(CC) : $(notdir $<)
	@$(CC) -c -o $@ $(CFLAGS) $<
#
$(TARGET)$(EXE): $(OBJS)
	$(CXX) $(CXXFLAGS) -o $@  $^  $(LIBS)
	@-$(STRIP)
#
$(BUILD_DIR):
	@-mkdir $@
#
run: all
	./$(TARGET)
#
genbind: gen bc
#
clean:
	@-rm $(TARGET)$(EXE)
	@-rm $(TARGET).o
	@-rm $(CIMGUI_ROOT)/*.o
	@-rm $(BUILD_DIR)/*
#
include gen.mk
