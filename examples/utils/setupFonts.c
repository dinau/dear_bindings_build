#include <float.h>
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>

#include "cimgui.h"
#include "utils.h"
#include "setupFonts.h"

const char* IconFontPath = "../utils/fonticon/fa6/fa-solid-900.ttf";
const char* JpFontName   = "meiryo.ttc";
char sBufFontPath[2048];

/*-----------------
 * getFontPath()
 *----------------*/
char* getFontPath(char* sBuf, int bufSize, const char* fontName) {
  char* sWinDir = getenv("windir");
  if (sWinDir == NULL) return NULL;
  snprintf(sBuf, bufSize, "%s\\Fonts\\%s", sWinDir, fontName);
  return sBuf;
}

/*------------
 * point2px()
 *-----------*/
float point2px(float point) {
  //## Convert point to pixel
  return (point * 96) / 72;
}

const ImFontConfig config = {.FontDataOwnedByAtlas = true
                             , .FontNo = 0
                             , .OversampleH = 3
                             , .OversampleV = 1
                             , .PixelSnapH = false
                             , .GlyphMaxAdvanceX = FLT_MAX
                             , .RasterizerMultiply = 1.0
                             , .RasterizerDensity  = 1.0
                             , .MergeMode = true
                             , .EllipsisChar = -1};
const ImWchar ranges_icon_fonts[]  = {(ImWchar)ICON_MIN_FA, (ImWchar)ICON_MAX_FA, (ImWchar)0};

/*--------------
 * setupFonts()
 *-------------*/
void setupFonts(void) {
  ImGuiIO* pio = ImGui_GetIO();
  ImFontAtlas_AddFontDefault(pio->Fonts, NULL);
  ImFontAtlas_AddFontFromFileTTF(pio->Fonts, IconFontPath, point2px(10), &config
                                , ranges_icon_fonts);
  char* fontPath = getFontPath(sBufFontPath, sizeof(sBufFontPath), JpFontName);
  if (false == existsFile(fontPath)) {
    printf("Error!: Not found JpFontPath: [%s] in %s\n", fontPath, __FILE__);
    return;
  }
  printf("Found JpFontPath: [%s]\n",fontPath);

  ImFont* font = ImFontAtlas_AddFontFromFileTTF(pio->Fonts, fontPath, point2px(14)
                                , &config
                                , ImFontAtlas_GetGlyphRangesJapanese(pio->Fonts));
  if (font == NULL) {
    printf("Error!: AddFontFromFileTTF():  [%s] \n", fontPath);
  }
}
