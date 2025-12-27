# Add backend driver in imgui
BACKEND_SRCS_CPP += imgui_impl_win32.cpp
BACKEND_SRCS_CPP += imgui_impl_dx11.cpp
BACKEND_SRCS_CPP += dcimgui_impl_win32.cpp
BACKEND_SRCS_CPP += dcimgui_impl_dx11.cpp

#
CFLAGS += -DCIMGUI_USE_WIN32
CFLAGS += -DCIMGUI_USE_DX11

# GLFW settings
LIBS   += -L.
LIBS = -ld3d11 -ldxgi -luser32 -lgdi32 -limm32 -ldxguid -ldwmapi -ld3dcompiler_47
