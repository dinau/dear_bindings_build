#include "utils_dcimgui.h"

CIMGUI_API ImFontConfig* ImFontConfig_new(void)
{
    return IM_NEW(ImFontConfig)();
}
