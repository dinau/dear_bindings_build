#pragma once

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

typedef unsigned int gluint;
unsigned int  LoadTextureFromFile(const char* filename, gluint* out_texture, int* out_width, int* out_height);
void loadTextureFromBuffer(gluint* textureID, int xs, int ys, int imageWidth, int imageHeight);
void LoadTitleBarIcon(void* window, const char* iconName);

#ifdef __cplusplus
}
#endif /* __cplusplus */
