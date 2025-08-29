
#include "dcimgui.h"
//#include "cimgui_impl.h"
#include <SDL_gpu.h>

typedef struct {
   SDL_GPUDevice* Device;
   SDL_GPUTextureFormat ColorTargetFormat;
   SDL_GPUSampleCount MSAASamples;
} ImGui_ImplSDLGPU3_InitInfo;

//#type
//  #struct_SDL_Renderer {.incompleteStruct.} = object
//  #SDL_Renderer = structsdlrenderer
//  #ImDrawData*  {.incompleteStruct.} = object

bool cImGui_ImplSDLGPU3_Init(ImGui_ImplSDLGPU3_InitInfo* info);
void cImGui_ImplSDLGPU3_Shutdown();
void cImGui_ImplSDLGPU3_NewFrame();
void cImGui_ImplSDLGPU3_PrepareDrawData(ImDrawData* draw_data ,SDL_GPUCommandBuffer* command_buffer);
void cImGui_ImplSDLGPU3_RenderDrawData(ImDrawData* draw_data
    ,SDL_GPUCommandBuffer* command_buffer
    ,SDL_GPURenderPass* render_pass
    ,SDL_GPUGraphicsPipeline* pipeline);
void cImGui_ImplSDLGPU3_CreateDeviceObjects();
void cImGui_ImplSDLGPU3_DestroyDeviceObjects();
void cImGui_ImplSDLGPU3_CreateFontsTexture();
void cImGui_ImplSDLGPU3_DestroyFontsTexture();
