#include <stdio.h>
#include <stdint.h>
#include <GLFW/glfw3.h>

#include "dcimgui.h"
#include "dcimgui_impl_glfw.h"
#include "dcimgui_impl_opengl3.h"

#include "setupFonts.h"
#include "loadImage.h"
#include "utils.h"
#include "stb_image.h"

GLFWwindow *window;
unsigned char* pIconData;  // == 0,  Memory pointer for icon.

int main(int argc, char *argv[]) {
  (void)argc; (void) argv;
  if (!glfwInit()) return -1;

  // Decide GL+GLSL versions
  glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GLFW_TRUE);
  glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);

  glfwWindowHint(GLFW_VISIBLE, GLFW_FALSE);

  const char *glsl_version = "#version 130";

  // just an extra window hint for resize
  glfwWindowHint(GLFW_RESIZABLE, GLFW_TRUE);

  window = glfwCreateWindow(1024, 900, "ImGui window", NULL, NULL);
  if (!window) {
    printf("Failed to create window! Terminating!\n");
    glfwTerminate();
    return -1;
  }

  glfwMakeContextCurrent(window);

  glfwSwapInterval(1);  // Enable Vsync

  // Load title bar icon
  const char* IconName = "icon_qr_my_github_red.png";
  pIconData = LoadTitleBarIcon(window, IconName);

  printf("opengl version: %s\n", (char *)glGetString(GL_VERSION));
  // setup imgui
  ImGui_CreateContext(NULL);

  // set docking
  ImGuiIO *ioptr = ImGui_GetIO();
  ioptr->ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;   // Enable Keyboard Controls
  //ioptr->ConfigFlags |= ImGuiConfigFlags_NavEnableGamepad;  // Enable Gamepad Controls
#ifdef IMGUI_HAS_DOCK
  ioptr->ConfigFlags |= ImGuiConfigFlags_DockingEnable;       // Enable Docking
  ioptr->ConfigFlags |= ImGuiConfigFlags_ViewportsEnable;     // Enable Multi-Viewport / Platform Windows
#endif

  cImGui_ImplGlfw_InitForOpenGL(window, true);
  cImGui_ImplOpenGL3_InitEx(glsl_version);

  bool showDemoWindow = true;
  bool showAnotherWindow = false;
  ImVec4 clearColor = {.x = 0.25f, .y = 0.55f, .z = 0.90f, .w = 1.00f};
  char sBuf[200];
  for (int i = 0; i<sizeof(sBuf); i++) {
    sBuf[i] = '\0';
  }

  ImGui_StyleColorsDark(NULL);
  // ImGui_StyleColorsClassic(NULL);

  setupFonts();

  /*------------
  # Load image
  #------------*/
  const char* ImageName = "fuji-400.jpg";
  GLuint textureId;
  int textureWidth = 0;
  int textureHeight = 0;
  LoadTextureFromFile(ImageName, &textureId, &textureWidth, &textureHeight);

  int showWindowDelay = 2;

  // main event loop
  // bool quit = false;
  while (!glfwWindowShouldClose(window)) {
    glfwPollEvents();
    // start imgui frame
    cImGui_ImplOpenGL3_NewFrame();
    cImGui_ImplGlfw_NewFrame();
    ImGui_NewFrame();

    if (showDemoWindow) ImGui_ShowDemoWindow(&showDemoWindow);
    // show a simple window that we created ourselves.
    {
      static float fval = 0.0f;
      static int counter = 0;
      if (ImGui_Begin(ICON_FA_THUMBS_UP " " "ImGui: Dear_Bindings", NULL, 0)) {
        ImGui_Text(ICON_FA_COMMENT" " "GLFW v"); ImGui_SameLine();
        ImGui_Text("%s", glfwGetVersionString());
        ImGui_Text(ICON_FA_COMMENT" " "OpenGL v"); ImGui_SameLine();
        ImGui_Text("%s", (char *)glGetString(GL_VERSION));
        ImGui_InputTextWithHint("InputText", "Input text here", sBuf, sizeof(sBuf), 0);
        ImGui_Text("Input result:"); ImGui_SameLine(); ImGui_Text("%s", sBuf);
        ImGui_Checkbox("Demo window", &showDemoWindow);
        ImGui_Checkbox("Another window", &showAnotherWindow);

        ImGui_SliderFloatEx("Float", &fval, 0.0f, 1.0f, "%.3f", 0);
        ImGui_ColorEdit3("clear color", (float *)&clearColor, 0);

        if (ImGui_Button("Button")) counter++;
        ImGui_SameLine();
        ImGui_Text("counter = %d", counter);
        ImGui_Text("Application average %.3f ms/frame (%.1f FPS)",
            1000.0f / ImGui_GetIO()->Framerate, ImGui_GetIO()->Framerate);
        //
        ImGui_SeparatorText(ICON_FA_WRENCH" Icon font test ");
        ImGui_Text(ICON_FA_TRASH_CAN  " Trash");
        ImGui_Text(ICON_FA_MAGNIFYING_GLASS_PLUS
            " " ICON_FA_POWER_OFF
            " " ICON_FA_MICROPHONE
            " " ICON_FA_MICROCHIP
            " " ICON_FA_VOLUME_HIGH
            " " ICON_FA_SCISSORS
            " " ICON_FA_SCREWDRIVER_WRENCH
            " " ICON_FA_BLOG);
        ImGui_End();
      }
    }

    if (showAnotherWindow) {
      ImGui_Begin("imgui Another Window", &showAnotherWindow, 0);
      ImGui_Text("Hello from imgui");
      if (ImGui_Button("Close me")) {
        showAnotherWindow = false;
      }
      ImGui_End();
    }

    //# Show image load window
    if (ImGui_Begin("Image load test", NULL, 0)) {
      //# Load image
      ImVec2 size = {.x = (float)textureWidth, .y = (float)textureHeight};
      ImGui_SetNextWindowSize(size, ImGuiCond_Always);
      ImGui_ImageEx((ImTextureRef){._TexData = NULL, ._TexID = textureId} ,size ,(ImVec2){.x = 0, .y = 0} ,(ImVec2){.x = 1, .y = 1});
      ImGui_End();
    }

    // render
    ImGui_Render();
    glfwMakeContextCurrent(window);
    glViewport(0, 0, (int)ioptr->DisplaySize.x, (int)ioptr->DisplaySize.y);
    glClearColor(clearColor.x, clearColor.y, clearColor.z, clearColor.w);
    glClear(GL_COLOR_BUFFER_BIT);
    cImGui_ImplOpenGL3_RenderDrawData(ImGui_GetDrawData());
#ifdef IMGUI_HAS_DOCK
    if (ioptr->ConfigFlags & ImGuiConfigFlags_ViewportsEnable) {
      GLFWwindow *backup_current_window = glfwGetCurrentContext();
      ImGui_UpdatePlatformWindows();
      ImGui_RenderPlatformWindowsDefault();
      glfwMakeContextCurrent(backup_current_window);
    }
#endif
    glfwSwapBuffers(window);

    if (showWindowDelay > 0) showWindowDelay--;
    if (showWindowDelay == 0) glfwShowWindow(window);

  }

  // clean up
  if (pIconData != 0) {
    stbi_image_free(pIconData);  // free memory for icon
  }
  cImGui_ImplOpenGL3_Shutdown();
  cImGui_ImplGlfw_Shutdown();
  ImGui_DestroyContext(NULL);

  glfwDestroyWindow(window);
  glfwTerminate();

  return 0;
}
