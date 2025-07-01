#include <GLFW/glfw3.h>
#include <stdio.h>

#include "dcimgui.h"
#include "dcimgui_impl_glfw.h"
#include "dcimgui_impl_opengl3.h"

#include "setupFonts.h"

// Constants
const char* SaveImageName = "ImageSaved";

// Global vars
GLFWwindow *window;
int cbItemIndex = 0;

typedef struct {
  char* kind;
  char* ext;
} TImageFormat;

TImageFormat imageFormatTbl[] = {  {.kind = "JPEG 90%", .ext = ".jpg"}
                                 , {.kind = "PNG",      .ext = ".png"}
                                 , {.kind = "BMP",      .ext = ".bmp"}
                                 , {.kind = "TGA",      .ext = ".tga"}};

// External functions
void saveImage(char* fname, GLuint xs, GLuint ys, int imageWidth, int imageHeight, int comp /* = RGB*/, int quality /* = 90*/);

/*--------------
 * setTooltip()
 *-------------*/
void setTooltip(const char* str) {
  if (ImGui_IsItemHovered(ImGuiHoveredFlags_DelayNormal)) {
    if (ImGui_BeginTooltip()) {
      ImGui_Text("%s", str);
      ImGui_EndTooltip();
    }
  }
}

/*--------
 * main()
 *-------*/
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
  ImVec4 clearColor = {.x = 0.25f, .y = 0.55f, .z = 0.90f, .w = 1.00f};
  char sBuf[1024];
  for (int i = 0; i<sizeof(sBuf); i++) {
    sBuf[i] = '\0';
  }

  ImGui_StyleColorsClassic(NULL);

  setupFonts();

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
      static float fVal = 0.0f;
      static int counter = 0;
      char svName[1024];
      char sTooltipBuf[1024 * 2];
      if (ImGui_Begin(ICON_FA_THUMBS_UP" " "ImGui: Dear_Bindings", NULL, 0)) {
        ImGui_Text(ICON_FA_COMMENT" " "GLFW v"); ImGui_SameLine();
        ImGui_Text("%s" , glfwGetVersionString());
        ImGui_Text(ICON_FA_COMMENT" " "OpenGL v"); ImGui_SameLine();
        ImGui_Text("%s", (char *)glGetString(GL_VERSION));
        ImGui_InputTextWithHint("InputText","Input text here",sBuf, sizeof(sBuf), 0);
        ImGui_Text("Input result:"); ImGui_SameLine(); ImGui_Text("%s", sBuf);
        ImGui_Checkbox("Demo window", &showDemoWindow);
        ImGui_Checkbox("Another window", &showAnotherWindow);

        ImGui_SliderFloatEx("Float", &fVal, 0.0f, 1.0f, "%.3f", 0);
        ImGui_ColorEdit3("clear color", (float *)&clearColor, 0);

        // #-- Save button for capturing window image
        ImGui_PushIDInt(0);
        ImVec4 col1 = {.x = 0.7, .y = 0.7, .z = 0.0, .w = 1.0};
        ImGui_PushStyleColorImVec4(ImGuiCol_Button, col1);
        ImVec4 col2 = {.x = 0.8, .y = 0.8, .z = 0.0, .w = 1.0};
        ImGui_PushStyleColorImVec4(ImGuiCol_ButtonHovered, col2);
        ImVec4 col3 = {.x = 0.9, .y = 0.9, .z = 0.0, .w = 1.0};
        ImGui_PushStyleColorImVec4(ImGuiCol_ButtonActive, col3);
        ImVec4 col4 = {.x = 0.0, .y = 0.0, .z = 0.0, .w = 1.0};
        ImGui_PushStyleColorImVec4(ImGuiCol_Text, col4);

        // # Image save button
        char* imageExt = imageFormatTbl[cbItemIndex].ext;
        snprintf(svName, sizeof(svName), "%s_%05d%s", SaveImageName, counter, imageExt);
        if (ImGui_Button("Save Image")) {
          ImVec2 wkSize = ImGui_GetMainViewport()->WorkSize;
          // printf("%s, %lf, %lf\n", svName, wkSize.x, wkSize.y);
          saveImage(svName, 0, 0, wkSize.x, wkSize.y, 3, 90);    // # --- Save Image !
        }
        ImGui_PopStyleColorEx(4);
        ImGui_PopID();

      //#-- Show tooltip help
      snprintf(sTooltipBuf, sizeof(sTooltipBuf), "Save to \"%s\"", svName);
      setTooltip(sTooltipBuf);
      counter++;

      ImGui_SameLine();
      //#-- ComboBox: Select save image format
      ImGui_SetNextItemWidth(100);
      if (ImGui_BeginCombo("##", imageFormatTbl[cbItemIndex].kind, 0)) {
        for (int n = 0; n < sizeof(imageFormatTbl)/sizeof(TImageFormat); n++) {
          bool is_selected = (cbItemIndex == n);
          if (ImGui_SelectableBoolPtr(imageFormatTbl[n].kind, &is_selected, 0)) {
            if (is_selected) {
              ImGui_SetItemDefaultFocus();
            }
            cbItemIndex = n;
          }
        }
        ImGui_EndCombo();
      }
      setTooltip("Select image format");
      //
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
  cImGui_ImplOpenGL3_Shutdown();
  cImGui_ImplGlfw_Shutdown();
  ImGui_DestroyContext(NULL);

  glfwDestroyWindow(window);
  glfwTerminate();

  return 0;
}
