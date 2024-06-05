#pragma once
unsigned char* LoadTextureFromFile(const char* filename, GLuint* out_texture, int* out_width, int* out_height);

#ifdef CIMGUI_USE_GLFW
uint8_t* LoadTitleBarIcon(GLFWwindow* window, const char* iconName);
#endif
