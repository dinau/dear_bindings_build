// THIS FILE HAS BEEN AUTO-GENERATED BY THE 'DEAR BINDINGS' GENERATOR.
// **DO NOT EDIT DIRECTLY**
// https://github.com/dearimgui/dear_bindings

// dear imgui: Platform Backend for SDL3 (*EXPERIMENTAL*)
// This needs to be used along with a Renderer (e.g. DirectX11, OpenGL3, Vulkan..)
// (Info: SDL3 is a cross-platform general purpose library for handling windows, inputs, graphics context creation, etc.)
// (IMPORTANT: SDL 3.0.0 is NOT YET RELEASED. IT IS POSSIBLE THAT ITS SPECS/API WILL CHANGE BEFORE RELEASE)

// Implemented features:
//  [X] Platform: Clipboard support.
//  [X] Platform: Mouse support. Can discriminate Mouse/TouchScreen.
//  [X] Platform: Keyboard support. Since 1.87 we are using the io.AddKeyEvent() function. Pass ImGuiKey values to all key functions e.g. ImGui::IsKeyPressed(ImGuiKey_Space). [Legacy SDL_SCANCODE_* values will also be supported unless IMGUI_DISABLE_OBSOLETE_KEYIO is set]
//  [X] Platform: Gamepad support. Enabled with 'io.ConfigFlags |= ImGuiConfigFlags_NavEnableGamepad'.
//  [X] Platform: Mouse cursor shape and visibility. Disable with 'io.ConfigFlags |= ImGuiConfigFlags_NoMouseCursorChange'.
// Missing features:
//  [ ] Platform: IME SUPPORT IS BROKEN IN SDL3 BECAUSE INPUTS GETS SENT TO BOTH APP AND IME + app needs to call 'SDL_SetHint(SDL_HINT_IME_SHOW_UI, "1");' before SDL_CreateWindow()!.

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
#include "cimgui.h"
#ifndef IMGUI_DISABLE
typedef struct SDL_Window SDL_Window;
typedef struct SDL_Renderer SDL_Renderer;
typedef struct SDL_Gamepad SDL_Gamepad;
typedef union SDL_Event SDL_Event;
typedef struct ImDrawData_t ImDrawData;

CIMGUI_IMPL_API bool cImGui_ImplSDL3_InitForOpenGL(SDL_Window* window, void* sdl_gl_context);
CIMGUI_IMPL_API bool cImGui_ImplSDL3_InitForVulkan(SDL_Window* window);
CIMGUI_IMPL_API bool cImGui_ImplSDL3_InitForD3D(SDL_Window* window);
CIMGUI_IMPL_API bool cImGui_ImplSDL3_InitForMetal(SDL_Window* window);
CIMGUI_IMPL_API bool cImGui_ImplSDL3_InitForSDLRenderer(SDL_Window* window, SDL_Renderer* renderer);
CIMGUI_IMPL_API bool cImGui_ImplSDL3_InitForOther(SDL_Window* window);
CIMGUI_IMPL_API void cImGui_ImplSDL3_Shutdown(void);
CIMGUI_IMPL_API void cImGui_ImplSDL3_NewFrame(void);
CIMGUI_IMPL_API bool cImGui_ImplSDL3_ProcessEvent(const SDL_Event* event);

// Gamepad selection automatically starts in AutoFirst mode, picking first available SDL_Gamepad. You may override this.
// When using manual mode, caller is responsible for opening/closing gamepad.
typedef enum
{
    ImGui_ImplSDL3_GamepadMode_AutoFirst,
    ImGui_ImplSDL3_GamepadMode_AutoAll,
    ImGui_ImplSDL3_GamepadMode_Manual,
} ImGui_ImplSDL3_GamepadMode;
CIMGUI_IMPL_API void cImGui_ImplSDL3_SetGamepadMode(ImGui_ImplSDL3_GamepadMode mode); // Implied manual_gamepads_array = NULL, manual_gamepads_count = -1
CIMGUI_IMPL_API void cImGui_ImplSDL3_SetGamepadModeEx(ImGui_ImplSDL3_GamepadMode mode, SDL_Gamepad** manual_gamepads_array /* = NULL */, int manual_gamepads_count /* = -1 */);
#endif// #ifndef IMGUI_DISABLE
#ifdef __cplusplus
} // End of extern "C" block
#endif
