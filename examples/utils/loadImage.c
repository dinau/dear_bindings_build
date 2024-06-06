#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
#include <stdbool.h>
#include <GL/gl.h>
#include <GL/glext.h>

#include <stdio.h>
#include <stdint.h>
#include "utils.h"
#ifdef CIMGUI_USE_GLFW
#include <GLFW/glfw3.h>
#endif

// Simple helper function to load an image into a OpenGL texture with common settings
unsigned char* LoadTextureFromFile(const char* imageName, GLuint* out_texture, int* out_width, int* out_height) {
  unsigned char* image_data = NULL;
  if (!existsFile(imageName)) {
    printf("\nError!: Image file not found  error: %s", imageName);
    return image_data;
  }
  // Load from file
  image_data = stbi_load(imageName, out_width, out_height, NULL, 4);
  if (image_data == NULL) {
    *out_texture = (GLuint)0;
    printf("\nError!: Image load error:  %s", imageName);
    return NULL;
  }
  // Create a OpenGL texture identifier
  glGenTextures(1, out_texture);
  glBindTexture(GL_TEXTURE_2D, *out_texture);

  // Setup filtering parameters for display
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE); // This is required on WebGL for non power-of-two textures
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE); // Same

  // Upload pixels into texture
#if defined(GL_UNPACK_ROW_LENGTH) && !defined(__EMSCRIPTEN__)
  glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
#endif
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, *out_width, *out_height, 0, GL_RGBA, GL_UNSIGNED_BYTE, image_data);
  // Free image memory
  stbi_image_free(image_data);

  return image_data;
}

#ifdef CIMGUI_USE_GLFW
/*--------------------
 * LoadTitleBarIcon()
 * ------------------*/
uint8_t* LoadTitleBarIcon(GLFWwindow* window, const char* iconName) {
  int width, height, channels, compo;
  uint8_t*  pixels = 0;
  if (existsFile(iconName)) {
    pixels = stbi_load(iconName, &width, &height, &channels, compo);
    const GLFWimage img  = {.width = width, .height = height, .pixels = pixels};
    glfwSetWindowIcon(window, 1, &img);
  } else {
    printf("\nNot found: %s",iconName);
    glfwSetWindowIcon(window, 0, NULL);
  }
  return pixels;
}
#endif
