#ifndef CIMGUICTE_INCLUDED
#define CIMGUICTE_INCLUDED

#include "cimgui.h"

#ifdef CIMGUI_DEFINE_ENUMS_AND_STRUCTS
#include "imgui_structs.h"
#else
#endif // CIMGUI_DEFINE_ENUMS_AND_STRUCTS

#include "auto_funcs.h"

///////////////manual generated
CIMGUI_API void TextEditor_SetText(TextEditor* self,const char* aText);
//allocates new memory that must be freed with TextEditor_GetText_free
CIMGUI_API char* TextEditor_GetText_alloc(TextEditor* self);
CIMGUI_API void TextEditor_GetText_free(char* ptr);
//returned value must be used to copy value before calling TextEditor_GetText_static again
CIMGUI_API const char* TextEditor_GetText_static(TextEditor* self);
//does as TextEditor_GetText_static
CIMGUI_API const char* TextEditor_GetText(TextEditor* self);
CIMGUI_API void TextEditor_ImGuiDebugPanel(TextEditor* self,const char* panelName);
#endif //CIMGUICTE_INCLUDED




