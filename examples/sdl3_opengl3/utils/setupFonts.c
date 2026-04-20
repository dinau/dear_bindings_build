#include <float.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "dcimgui.h"
#include "setupFonts.h"

#define MAX_PATH  2048
const char* IconFontPath = "resources/fonticon/fa6/fa-solid-900.ttf";
char sBufFontPath[MAX_PATH];

char WinFontNameTbl[][MAX_PATH] = {
                                  "meiryo.ttc"     // Windows 7,8
                                 ,"YuGothM.ttc"    // Windows 10
                                 ,"segoeui.ttf"    // English standard
                                 };
char LinuxFontNameTbl[][MAX_PATH] = { // For Linux Mint 22 (Ubuntu/Debian family ok ?)
                            "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc"          // JP
                           ,"/usr/share/fonts/opentype/ipafont-gothic/ipag.ttf"               // Debian
                           ,"/usr/share/fonts/opentype/ipafont-gothic/ipam.ttf"               // Debian
                           ,"/usr/share/fonts/truetype/liberation/LiberationMono-Regular.ttf" // Linux Mint English
                           ,"/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf",            // English region standard font
                           };

/*-------------
 * existFile()
 * -----------*/
static bool existsFile(const char* path) {
  if (path == NULL){
    return false;
  }
  FILE* fp = fopen(path, "r");
  if (fp == NULL) return false;
  fclose(fp);
  return true;
}

/*-----------------
 * getWinFontPath()
 *----------------*/
char* getWinFontPath(char* sBuf, int bufSize, const char* fontName) {
  char* sWinDir = getenv("windir");
  if (sWinDir == NULL) return NULL;
  snprintf(sBuf, bufSize, "%s\\Fonts\\%s", sWinDir, fontName);
  return sBuf;
}

/*------------
 * point2px()
 *-----------*/
float point2px(float point) { //## Convert point to pixel
  return (point * 96) / 72;
}

static ImFontConfig* config;
CIMGUI_API ImFontConfig* ImFontConfig_ImFontConfig(void);

/*--------------
 * setupFonts()
 *-------------*/
ImFont* setupFonts(void) {
  ImGuiIO* pio = ImGui_GetIO();
  config  = ImFontConfig_ImFontConfig(); // TODO free()
  ImFont* font = NULL;
  char* fontPath;
  // Try Windows fonts
  int tableLen = sizeof(WinFontNameTbl) / MAX_PATH;
  for(int i=0; i<tableLen; i++){
    fontPath = getWinFontPath(sBufFontPath, sizeof(sBufFontPath), WinFontNameTbl[i]);
    if (existsFile(fontPath)) {
      font = ImFontAtlas_AddFontFromFileTTF(pio->Fonts, fontPath, point2px(14.5)
          , NULL
          , NULL);
      printf("Found FontPath: [%s]\n",fontPath);
      break;
    }
  }
  // Try Linux fonts if Windows fonts not found
  if(font == NULL){
    tableLen = sizeof(LinuxFontNameTbl) / MAX_PATH;
    for(int i=0; i<tableLen; i++){
      fontPath = LinuxFontNameTbl[i];
      if (existsFile(fontPath)) {
        font = ImFontAtlas_AddFontFromFileTTF(pio->Fonts, fontPath, point2px(13)
            , NULL
            , NULL);
        printf("Found FontPath: [%s]\n",fontPath);
        break;
      }
    }
  }
  // Use default font if no font found
  if (font == NULL) {
    printf("Error!: Font loading falied: in %s\n", __FILE__);
    printf("Default has been set.\n");
    ImFontAtlas_AddFontDefaultVector(pio->Fonts, NULL);
  }
  // Merge IconFont
  config->MergeMode = true;
  if (existsFile(IconFontPath)) {
    return ImFontAtlas_AddFontFromFileTTF(pio->Fonts, IconFontPath, point2px(11), config , NULL);
  } else{
    printf("Error!: Font not found [ %s ]:  falied: in %s\n", IconFontPath, __FILE__);
    return 0;
  }
}
