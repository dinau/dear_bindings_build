// THIS FILE HAS BEEN AUTO-GENERATED BY THE 'DEAR BINDINGS' GENERATOR.
// **DO NOT EDIT DIRECTLY**
// https://github.com/dearimgui/dear_bindings

// dear imgui: Platform Backend for SDL2
// ImDrawIdx: vertex index. [Compile-time configurable type]
// - To use 16-bit indices + allow large meshes: backend need to set 'io.BackendFlags |= ImGuiBackendFlags_RendererHasVtxOffset' and handle ImDrawCmd::VtxOffset (recommended).
// - To use 32-bit indices: override with '#define ImDrawIdx unsigned int' in your imconfig.h file.
#ifndef ImDrawIdx
typedef unsigned short ImDrawIdx;  // Default: 16-bit (for maximum compatibility with renderer backends)
#endif // #ifndef ImDrawIdx
// This needs to be used along with a Renderer (e.g. DirectX11, OpenGL3, Vulkan..)
// (Info: SDL2 is a cross-platform general purpose library for handling windows, inputs, graphics context creation, etc.)

// Implemented features:
//  [X] Platform: Clipboard support.
//  [X] Platform: Mouse support. Can discriminate Mouse/TouchScreen.
//  [X] Platform: Keyboard support. Since 1.87 we are using the io.AddKeyEvent() function. Pass ImGuiKey values to all key functions e.g. ImGui::IsKeyPressed(ImGuiKey_Space). [Legacy SDL_SCANCODE_* values are obsolete since 1.87 and not supported since 1.91.5]
//  [X] Platform: Gamepad support.
//  [X] Platform: Mouse cursor shape and visibility (ImGuiBackendFlags_HasMouseCursors). Disable with 'io.ConfigFlags |= ImGuiConfigFlags_NoMouseCursorChange'.
//  [X] Platform: Basic IME support. App needs to call 'SDL_SetHint(SDL_HINT_IME_SHOW_UI, "1");' before SDL_CreateWindow()!.
//  [X] Platform: Multi-viewport support (multiple windows). Enable with 'io.ConfigFlags |= ImGuiConfigFlags_ViewportsEnable'.
// Missing features or Issues:
//  [ ] Platform: Multi-viewport: Minimized windows seems to break mouse wheel events (at least under Windows).
//  [ ] Platform: Multi-viewport: ParentViewportID not honored, and so io.ConfigViewportsNoDefaultParent has no effect (minor).

// You can use unmodified imgui_impl_* files in your project. See examples/ folder for examples of using this.
// Prefer including the entire imgui/ repository into your project (either as a copy or as a submodule), and only build the backends you need.
// Learn about Dear ImGui:
// - FAQ                  https://dearimgui.com/faq
// - Getting Started      https://dearimgui.com/getting-started
// - Documentation        https://dearimgui.com/docs (same as your local docs/ folder).
// - Introduction, links and more at the top of imgui.cpp

#pragma once

#ifdef __cplusplus
extern "C"
{
#endif
#include "dcimgui.h"
#ifndef IMGUI_DISABLE
typedef struct SDL_Window SDL_Window;
typedef struct SDL_Renderer SDL_Renderer;
typedef struct _SDL_GameController _SDL_GameController;
typedef union SDL_Event SDL_Event;

typedef struct ImDrawData_t ImDrawData;
// Follow "Getting Started" link and check examples/ folder to learn about using backends!
CIMGUI_IMPL_API bool cImGui_ImplSDL2_InitForOpenGL(SDL_Window* window, void* sdl_gl_context);
CIMGUI_IMPL_API bool cImGui_ImplSDL2_InitForVulkan(SDL_Window* window);
CIMGUI_IMPL_API bool cImGui_ImplSDL2_InitForD3D(SDL_Window* window);
CIMGUI_IMPL_API bool cImGui_ImplSDL2_InitForMetal(SDL_Window* window);
CIMGUI_IMPL_API bool cImGui_ImplSDL2_InitForSDLRenderer(SDL_Window* window, SDL_Renderer* renderer);
CIMGUI_IMPL_API bool cImGui_ImplSDL2_InitForOther(SDL_Window* window);
CIMGUI_IMPL_API void cImGui_ImplSDL2_Shutdown(void);
CIMGUI_IMPL_API void cImGui_ImplSDL2_NewFrame(void);
CIMGUI_IMPL_API bool cImGui_ImplSDL2_ProcessEvent(const SDL_Event* event);

// DPI-related helpers (optional)
CIMGUI_IMPL_API float cImGui_ImplSDL2_GetContentScaleForWindow(SDL_Window* window);
CIMGUI_IMPL_API float cImGui_ImplSDL2_GetContentScaleForDisplay(int display_index);

// Gamepad selection automatically starts in AutoFirst mode, picking first available SDL_Gamepad. You may override this.
// When using manual mode, caller is responsible for opening/closing gamepad.
typedef enum
{
    ImGui_ImplSDL2_GamepadMode_AutoFirst,
    ImGui_ImplSDL2_GamepadMode_AutoAll,
    ImGui_ImplSDL2_GamepadMode_Manual,
} ImGui_ImplSDL2_GamepadMode;
CIMGUI_IMPL_API void cImGui_ImplSDL2_SetGamepadMode(ImGui_ImplSDL2_GamepadMode mode); // Implied manual_gamepads_array = nullptr, manual_gamepads_count = -1
CIMGUI_IMPL_API void cImGui_ImplSDL2_SetGamepadModeEx(ImGui_ImplSDL2_GamepadMode mode, _SDL_GameController** manual_gamepads_array /* = nullptr */, int manual_gamepads_count /* = -1 */);
#endif// #ifndef IMGUI_DISABLE
#ifdef __cplusplus
} // End of extern "C" block
#endif
