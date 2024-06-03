<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [dear_bindings_build](#dear_bindings_build)
  - [Prerequisite](#prerequisite)
  - [Build and run](#build-and-run)
  - [Examples screen shots](#examples-screen-shots)
  - [Regenarate ImGui bindings](#regenarate-imgui-bindings)
  - [Compiling with Clang, Zig cc](#compiling-with-clang-zig-cc)
  - [My tools version](#my-tools-version)
  - [Similar porject](#similar-porject)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# dear_bindings_build

This project aims to simply build ImGui examples using [Dear_Bindings](https://github.com/dearimgui/dear_bindings)  
and now highly work in progress.


ImGui version **1.90.8 WIP** (2024/05)

## Prerequisite

---

- Windows10 OS
- GCC (or Clang or **'Zig cc'** compiler)
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
   make                # or 'make run'
   ./glfw_opengl3.exe  # run application
   ```

## Examples screen shots 

---

- [glfw_opengl3](examples/glfw_opengl3)  
![alt](img/glfw_opengl3.png)

- [glfw_opengl3_jp](examples/glfw_opengl3_jp)  
![alt](img/glfw_opengl3_jp.png)

- [sdl2_opengl3_jp](examples/sdl2_opengl3_jp)  
![alt](img/sdl2_opengl3.png)

## Regenarate ImGui bindings


---

```sh
pwd 
glfw_opengl3
make cleanall
make gen
make run
```

Artifacts are generated into **./cimgui** folder.

## Build with Clang, Zig cc 

---

For instance,

```sh 
pwd 
glfw_opengl3
make TC=clang    # or TC=zig
```

## My tools version

---

- clang version 18.1.6
- ~~cmake version 3.28.0-rc2~~
- gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
- git version 2.41.0.windows.3
- make: GNU Make 4.2.1
- Python 3.12.3
- zig: 0.12.0 (zig cc: clang version 17.0.6)
- SDL2 ver.2.30.3

## Similar project

---

- **Nim** language  
[Imguin](https://github.com/dinau/imguin), [Nimgl_test](https://github.com/dinau/nimgl_test), [Nim_implot](https://github.com/dinau/nim_implot)
- **Lua** lanugage  
[LuaJITImGui](https://github.com/dinau/luajitimgui)
- **Python** language  
[DearPyGui for 32bit WindowsOS Binary](https://github.com/dinau/DearPyGui32/tree/win32)
