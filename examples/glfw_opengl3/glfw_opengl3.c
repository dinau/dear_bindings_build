#include "cimgui.h"
#include <GLFW/glfw3.h>
#include <stdio.h>

#include "cimgui_impl_glfw.h"
#include "cimgui_impl_opengl3.h"

GLFWwindow *window;

int main(int argc, char *argv[]) {
  if (!glfwInit()) return -1;

  // Decide GL+GLSL versions
  glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GLFW_TRUE);
  glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);

  const char *glsl_version = "#version 130";

  // just an extra window hint for resize
  glfwWindowHint(GLFW_RESIZABLE, GLFW_TRUE);

  window = glfwCreateWindow(1024, 768, "ImGui window", NULL, NULL);
  if (!window) {
    printf("Failed to create window! Terminating!\n");
    glfwTerminate();
    return -1;
  }

  glfwMakeContextCurrent(window);
  // enable vsync
  glfwSwapInterval(1);
  // check opengl version sdl uses
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

  ImGui_StyleColorsDark(NULL);
  // ImFontAtlas_AddFontDefault(io.Fonts, NULL);

  bool showDemoWindow = true;
  bool showAnotherWindow = false;
  ImVec4 clearColor = {.x = 0.25f
                      ,.y = 0.55f
                      ,.z = 0.90f
                      ,.w = 1.00f};

  ImGui_StyleColorsClassic(NULL);

  // main event loop
  bool quit = false;
  while (!glfwWindowShouldClose(window)) {
    glfwPollEvents();
    // start imgui frame
    cImGui_ImplOpenGL3_NewFrame();
    cImGui_ImplGlfw_NewFrame();
    ImGui_NewFrame();

    if (showDemoWindow) ImGui_ShowDemoWindow(&showDemoWindow);
    // show a simple window that we created ourselves.
    {
      static float f = 0.0f;
      static int counter = 0;
      static char sBuf[200];
      if(ImGui_Begin("ImGui: Dear_Bindings", NULL, 0)){
        ImGui_Text("GLFW v"); ImGui_SameLine();
        ImGui_Text(glfwGetVersionString());
        ImGui_Text("OpenGL v"); ImGui_SameLine();
        ImGui_Text((char *)glGetString(GL_VERSION));
        ImGui_InputTextWithHint("InputText","Input text here",sBuf,sizeof(sBuf),0);
        ImGui_Text("Input result:"); ImGui_SameLine(); ImGui_Text(sBuf);
        ImGui_Checkbox("Demo window", &showDemoWindow);
        ImGui_Checkbox("Another window", &showAnotherWindow);

        ImGui_SliderFloatEx("Float", &f, 0.0f, 1.0f, "%.3f", 0);
        ImGui_ColorEdit3("clear color", (float *)&clearColor, 0);

        if (ImGui_Button("Button")) counter++;
        ImGui_SameLine();
        ImGui_Text("counter = %d", counter);
        ImGui_Text("Application average %.3f ms/frame (%.1f FPS)",
               1000.0f / ImGui_GetIO()->Framerate, ImGui_GetIO()->Framerate);
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
  }

  // clean up
  cImGui_ImplOpenGL3_Shutdown();
  cImGui_ImplGlfw_Shutdown();
  ImGui_DestroyContext(NULL);

  glfwDestroyWindow(window);
  glfwTerminate();

  return 0;
}
