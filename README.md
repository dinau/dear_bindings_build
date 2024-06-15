<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Dear_Bindings_Build](#dear_bindings_build)
  - [Prerequisites](#prerequisites)
  - [Build and run](#build-and-run)
  - [Examples screen shots](#examples-screen-shots)
  - [Hiding console window](#hiding-console-window)
  - [Regenarate ImGui bindings](#regenarate-imgui-bindings)
  - [Build with Clang, Zig cc](#build-with-clang-zig-cc)
  - [My tools version](#my-tools-version)
  - [Similar project](#similar-project)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Dear_Bindings_Build

This project aims to simply and easily build ImGui examples with **C language** and **Zig language** using [Dear_Bindings](https://github.com/dearimgui/dear_bindings) and ImGui.

ImGui version **1.90.8 WIP** (2024/05)

## Prerequisites

---

- Windows10 OS
- GCC (or Clang or **'Zig cc'** compiler)
- Use **Zig: 0.12.0** (zig cc: clang version 17.0.6)
- Pyhton3
- MSys/MinGW basic commands (make, rm, cp ...)

## Build and run

---

1. Download this project.

   ```sh
   git clone --recurse-submodules https://github.com/dinau/dear_bindings_build
   ```
1. Go to one of the examples folder,

   ```sh
   cd dear_bindings_build/examples/glfw_opengl3
   ```

1. Build and Run 

   ```sh
   make run                
   ```

## Examples screen shots 

---

- C lang.  
[glfw_opengl3](examples/glfw_opengl3)  
[sdl2_opengl3](examples/sdl2_opengl3)  
[sdl3_opengl3](examples/sdl3_opengl3)  
- Zig lang.  
[zig_glfw_opengl3](examples/zig_glfw_opengl3)  
![alt](img/glfw_opengl3.png)

---

- [glfw_opengl3_jp](examples/glfw_opengl3_jp)  
![alt](img/glfw_opengl3_jp.png)


---

- [glfw_opengl3_image_load](examples/glfw_opengl3_image_load)
- [zig_glfw_opengl3_image_load](examples/zig_glfw_opengl3_image_load)  
![alt](img/glfw_opengl3_image_load.png)


---

- [glfw_opengl3_image_save](examples/glfw_opengl3_image_save)  
- [zig_glfw_opengl3_image_load](examples/zig_glfw_opengl3_image_load)  
![alt](img/glfw_opengl3_image_save.png)  
Image file captured would be saved in current folder.  
It can be saved as `JPEG / PNG / BMP / TGA` file.



## Hiding console window

---

- Zig lang. examples  
Open `build.zig` in each example folder and **enable** option line as follows,

  ```zig
  ... snip ...
  exe.subsystem = .Windows;  // Hide console window
  ... snip ...
  ```

  and execute `make`.


- C lang. examples  
Open `Makefile` in each example folder and **change** option as follows,

  ```Makefile
  ... snip ...
  HIDE_CONSOLE_WINDOW = true
  ... snip ...
  ```

  and execute `make`.


## Regenarate ImGui bindings

---

For instance,

```sh
pwd 
glfw_opengl3
make cleanall
make gen
make run
```

Artifacts are generated into `../libs/cimgui` folder.

## Build with Clang, Zig cc 

---

For instance,

```sh 
pwd 
glfw_opengl3
make cleanobjs   
make TC=clang    # or TC=zigcc
```

Compiling with `TC=zigcc` may link dynamic library at this time. 

Note: Except Zig lang. examples.

## My tools version

---

- clang version 18.1.6
- gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
- git version 2.41.0.windows.3
- make: GNU Make 4.3
- Python 3.12.3
- zig: 0.12.0 (zig cc: clang version 17.0.6)
- SDL2 ver.2.30.3
- SDL3 2024-06-02

## Similar project

---

- **Nim** language  
[Imguin](https://github.com/dinau/imguin), [Nimgl_test](https://github.com/dinau/nimgl_test), [Nim_implot](https://github.com/dinau/nim_implot)
- **Lua** lanugage  
[LuaJITImGui](https://github.com/dinau/luajitimgui)
- **Python** language  
[DearPyGui for 32bit WindowsOS Binary](https://github.com/dinau/DearPyGui32/tree/win32)
