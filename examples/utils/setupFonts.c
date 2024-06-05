#include <float.h>
#include <stdio.h>

#include "cimgui.h"
#include "utils.h"
#include "setupFonts.h"

const char* IconFontPath = "../utils/fonticon/fa6/fa-solid-900.ttf";
const char* JpFontPath   = "c:/Windows/Fonts/meiryo.ttc";


/*------------
 * point2px()
 *-----------*/
float point2px(float point){
  //## Convert point to pixel
  return (point * 96) / 72;
}

const ImFontConfig config = {.FontDataOwnedByAtlas = true
                             ,.FontNo = 0
                             ,.OversampleH = 3
                             ,.OversampleV = 1
                             ,.PixelSnapH = false
                             ,.GlyphMaxAdvanceX = FLT_MAX
                             ,.RasterizerMultiply = 1.0
                             ,.RasterizerDensity  = 1.0
                             ,.MergeMode = true
                             ,.EllipsisChar = -1};
const ImWchar ranges_icon_fonts[]  = {(ImWchar)ICON_MIN_FA,  (ImWchar)ICON_MAX_FA, (ImWchar)0};

/*--------------
 * setupFonts()
 *-------------*/
void setupFonts(void){
  ImGuiIO* pio = ImGui_GetIO();
  ImFontAtlas_AddFontDefault(pio->Fonts,NULL);
  ImFontAtlas_AddFontFromFileTTF(pio->Fonts, IconFontPath, point2px(10), &config
                                ,ranges_icon_fonts );
  if (false == existsFile(JpFontPath)){
    printf("Error!: Not found JpFontPath: [%s] in %s\n",JpFontPath,__FILE__);
    return;
  }
  ImFontAtlas_AddFontFromFileTTF(pio->Fonts,JpFontPath, point2px(14)
                                ,&config
                                ,ImFontAtlas_GetGlyphRangesJapanese(pio->Fonts));
}
