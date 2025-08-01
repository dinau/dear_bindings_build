#include <float.h>
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>

#include "dcimgui.h"
#include "setupFonts.h"

/*-------------
 * existFile()
 * -----------*/
static bool existsFile(const char* path) {
  FILE* fp = fopen(path, "r");
  if (fp == NULL) return false;
  fclose(fp);
  return true;
}

const char* IconFontPath = "../utils/fonticon/fa6/fa-solid-900.ttf";
char sBufFontPath[2048];

/*-----------------
 * getFontPath()
 *----------------*/
const char* WinJpFontName   = "meiryo.ttc";

char* getWinFontPath(char* sBuf, int bufSize, const char* fontName) {
  char* sWinDir = getenv("windir");
  if (sWinDir == NULL) return NULL;
  snprintf(sBuf, bufSize, "%s\\Fonts\\%s", sWinDir, fontName);
  return sBuf;
}
/*--------------------
 * getLinuxFontPath()
 *------------------*/
// For Linux Mint 22 (Ubuntu/Debian family ok ?)
#define MAX_FONT_NAME  100
char LinuxFontNameTbl[][MAX_FONT_NAME] = {
                            "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc"          // JP
                           ,"/usr/share/fonts/opentype/ipafont-gothic/ipag.ttf"               // Debian
                           ,"/usr/share/fonts/opentype/ipafont-gothic/ipam.ttf"               // Debian
                           ,"/usr/share/fonts/truetype/liberation/LiberationMono-Regular.ttf" // Linux Mint English
                           };

/*------------
 * point2px()
 *-----------*/
float point2px(float point) { //## Convert point to pixel
  return (point * 96) / 72;
}

ImFontConfig config = {.FontDataOwnedByAtlas = true
                             , .FontNo = 0
                             , .OversampleH = 3
                             , .OversampleV = 1
                             , .PixelSnapH = false
                             , .GlyphMaxAdvanceX = FLT_MAX
                             , .RasterizerMultiply = 1.0
                             , .RasterizerDensity  = 1.0
                             , .MergeMode = false
                             , .EllipsisChar = -1};
const ImWchar ranges_icon_fonts[]  = {(ImWchar)ICON_MIN_FA, (ImWchar)ICON_MAX_FA, (ImWchar)0};

/*--------------
 * setupFonts()
 *-------------*/
void setupFonts(void) {
  ImGuiIO* pio = ImGui_GetIO();
  ImFont* font = NULL;
  char* fontPath = getWinFontPath(sBufFontPath, sizeof(sBufFontPath), WinJpFontName);
  if (existsFile(fontPath)) {
      printf("Found JpFontPath: [%s]\n",fontPath);
      font = ImFontAtlas_AddFontFromFileTTF(pio->Fonts, fontPath, point2px(14.5)
                                    , &config
                                    , NULL);
  }else{
    int tableLen = sizeof(LinuxFontNameTbl) / MAX_FONT_NAME;
    for(int i=0; i<tableLen; i++){
      fontPath = LinuxFontNameTbl[i];
      if (existsFile(fontPath)) {
        font = ImFontAtlas_AddFontFromFileTTF(pio->Fonts, fontPath, point2px(13)
            , &config
            , NULL);
        printf("Found FontPath: [%s]\n",fontPath);
        break;
      }
    }
  }
  if (font == NULL) {
    printf("Error!: Not found FontPath: in %s\n", __FILE__);
    printf("Set default font.\n");
    ImFontAtlas_AddFontDefault(pio->Fonts, NULL);
  }
  // Merge IconFont
  config.MergeMode = true;
  ImFontAtlas_AddFontFromFileTTF(pio->Fonts, IconFontPath, point2px(11), &config , ranges_icon_fonts);
}
