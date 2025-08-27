#include <float.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "dcimgui.h"
#include "setupFonts.h"
#include "IconsFontAwesome6.h"

#define MAX_PATH  2048
const char* IconFontPath = "../utils/fonticon/fa6/fa-solid-900.ttf";
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
/*---------------------
 * ImFontConfig_create
 *--------------------*/
ImFontConfig* ImFontConfig_create(void) {
  size_t sz = sizeof(ImFontConfig);
  ImFontConfig* cfg = (ImFontConfig*) malloc(sz);
  memset(cfg, '\0', sz);
  cfg->FontDataOwnedByAtlas = true;
  cfg->FontNo = 0;
  cfg->OversampleH = 3;
  cfg->OversampleV = 1;
  cfg->PixelSnapH = false;
  cfg->GlyphMaxAdvanceX = FLT_MAX;
  cfg->RasterizerMultiply = 1.0;
  cfg->RasterizerDensity  = 1.0;
  cfg->MergeMode = false;
  cfg->EllipsisChar = (ImWchar)-1;
  return cfg;
}

const ImWchar ranges_icon_fonts[]  = {(ImWchar)ICON_MIN_FA, (ImWchar)ICON_MAX_FA, (ImWchar)0};
/*--------------
 * setupFonts()
 *-------------*/
void setupFonts(void) {
  ImGuiIO* pio = ImGui_GetIO();
  config  = ImFontConfig_create(); // TODO free()
  ImFont* font = NULL;
  char* fontPath;
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
  if (font == NULL) {
    printf("Error!: Font loading falied: in %s\n", __FILE__);
    printf("Default has been set.\n");
    ImFontAtlas_AddFontDefault(pio->Fonts, NULL);
  }
  // Merge IconFont
  config->MergeMode = true;
  ImFontAtlas_AddFontFromFileTTF(pio->Fonts, IconFontPath, point2px(11), config , ranges_icon_fonts);
}
