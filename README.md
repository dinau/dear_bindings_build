<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Dear_Bindings_Build](#dear_bindings_build)
  - [Features](#features)
  - [Available libraries list at this moment](#available-libraries-list-at-this-moment)
  - [Prerequisites](#prerequisites)
  - [Compiling](#compiling)
  - [Build and run](#build-and-run)
  - [Examples screen shots](#examples-screen-shots)
    - [zig_imknobs](#zig_imknobs)
    - [zig_imtoggle](#zig_imtoggle)
    - [zig_imspinner](#zig_imspinner)
    - [zig_imfiledialog](#zig_imfiledialog)
    - [zig_imgui_markdown](#zig_imgui_markdown)
    - [zig_iconfontviewer](#zig_iconfontviewer)
    - [zig_imcolortextedit](#zig_imcolortextedit)
    - [zig_imguizmo](#zig_imguizmo)
    - [zig_imnodes](#zig_imnodes)
    - [zig_implot / zig_implot3d](#zig_implot--zig_implot3d)
    - [Image load / save](#image-load--save)
    - [zig_glfw_opengl3](#zig_glfw_opengl3)
  - [Hiding console window](#hiding-console-window)
  - [SDL libraries](#sdl-libraries)
  - [My tools version](#my-tools-version)
  - [Similar project ImGui / CImGui](#similar-project-imgui--cimgui)
  - [SDL game tutorial Platfromer](#sdl-game-tutorial-platfromer)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![alt](https://github.com/dinau/dear_bindings_build/actions/workflows/win_rel.yml/badge.svg) 
![alt](https://github.com/dinau/dear_bindings_build/actions/workflows/linux_rel.yml/badge.svg)  
![alt](https://github.com/dinau/dear_bindings_build/actions/workflows/win_dev.yml/badge.svg) 
![alt](https://github.com/dinau/dear_bindings_build/actions/workflows/linux_dev.yml/badge.svg)

### Dear_Bindings_Build

This project aims to simply and easily build ImGui examples with **C language** and **Zig language** using [Dear_Bindings](https://github.com/dearimgui/dear_bindings) as first step.

[Dear ImGui](https://github.com/ocornut/imgui) version **1.92.2b** (2025/08)

#### Features

---

- [x] No download external libraries  
Included Dear_Bindings / Dear ImGui / GLFW / SDL3 / STB_image libraries in this project
- [x] Included IconFont [FontAwewsome 6](https://fontawesome.com)
- [x] Image load/save

- Frontends and Backends 

   |                     | GLFW   | SDL3   |
   | ---                 | :----: | :----: |
   | OpenGL3<br>backend  | v      | v      |
   | SDL3 GPU<br>backend | -      | WIP    |

#### Available libraries list at this moment

---

Library name / C lang. wrapper

- [x] [ImGui](https://github.com/ocornut/imgui) / [Dear_Bindings](https://github.com/dearimgui/dear_bindings)
- [x] [ImGui-Knobs](https://github.com/altschuler/imgui-knobs) / [CImGui-Knobs](libs/cimgui-knobs) (2025/07)
- [x] [ImGuiFileDialog](https://github.com/aiekick/ImGuiFileDialog) / [CImGuiFileDialog](https://github.com/dinau/CImGuiFileDialog) (2025/07)
- [x] [ImGui_Toggle](https://github.com/cmdwtf/imgui_toggle) / [CimGui_Toggle](https://github.com/dinau/cimgui_toggle) (2025/07)
- [x] [ImSpinner](https://github.com/dalerank/imspinner) / [CImSpinner](https://github.com/dinau/cimspinner) (2025/07)
- [x] [ImGuiColorTextEdit](https://github.com/santaclose/ImGuiColorTextEdit) / [cimCTE](https://github.com/cimgui/cimCTE) (2025/08)
- [x] [ImGuizmo](https://github.com/CedricGuillemet/ImGuizmo) / [CImGuizmo](https://github.com/cimgui/cimguizmo) (2025/08)
- [x] [ImNodes](https://github.com/Nelarius/imnodes) / [CImNodes](https://github.com/cimgui/cimnodes) (2025/08)
- [x] [ImPlot](https://github.com/epezent/implot) / [CImPlot](https://github.com/cimgui/cimplot)
- [x] [ImPlot3d](https://github.com/brenocq/implot3d) / [CImPlot3d](https://github.com/cimgui/cimplot3d) 
- [ ] [ImGui_Markdown](https://github.com/enkisoftware/imgui_markdown) (2025/09 WIP) 

#### Prerequisites

---

- Windows10 OS or later  
MSys/MinGW basic commands (make, rm, cp ...)
- Linux OS: Debian / Ubunts families
- GCC (or Clang or **'Zig cc'** compiler)
- Zig Compiler  
   Windows: [zig-x86_64-windows-0.15.1.zip](https://ziglang.org/download/0.15.1/zig-x86_64-windows-0.15.1.zip)  
   Linux:   [zig-x86_64-linux-0.15.1.tar.xz](https://ziglang.org/download/0.15.1/zig-x86_64-linux-0.15.1.tar.xz)

#### Compiling 

---

- GCC compiler

   | example                     | Windows | Linux  |
   | ---                         | :----:  | :----: |
   | glfw_opengl3                | v       |    -   |
   | glfw_opengl3_image_load     | v       |    -   |
   | glfw_opengl3_image_save     | v       |    -   |
   | glfw_opengl3_jp             | v       |    -   |
   | sdl3_opengl3                | v       |    -   |

- Zig compiler

   | Libs               | Example                     | Windows | Linux             |
   | ---                | ---                         | :----:  | :----:            |
   | -                  | zig_glfw_opengl3            | v       | v                 |
   | -                  | zig_glfw_opengl3_image_load | v       | v                 |
   | -                  | zig_iconfontviewer          | v       | v                 |
   | ImGuiFiledialog    | zig_imfiledialog            | v       | v                 |
   | ImGui-Knobs        | zig_imkonbs                 | v       | v                 |
   | ImSpinner          | zig_imspinner               | v       | v                 |
   | ImGui-Toggle       | zig_imtoggle                | v       | v                 |
   | ImGuiColorTextEdit | zig_imcolortextedit         | v       | v                 |
   | ImGuizmo           | zig_imguizmo                | v       | v                 |
   | ImNodes            | zig_imnodes                 | v       | v                 |
   | ImPlot             | zig_implot                  | v       | v                 |
   | ImPlot3D           | zig_implot3d                | v       | v                 |
   | ImGui_Markdown     | zig_imgui_markdown          | WIP     | WIP               |
   | -                  | zig_sdl3_opengl3            | v       | v [^sdl3_install] |

[^sdl3_install]: [Install SDL3 for Linux](https://github.com/dinau/sdl3_nim#for-linux-os)


#### Build and run

---

1. Download this project.

   ```sh
   git clone https://github.com/dinau/dear_bindings_build
   ```
1. Go to one of the examples folder,

   ```sh
   cd dear_bindings_build/examples/glfw_opengl3
   ```

1. Build and Run 

   ```sh
   make run                
   ```

#### Examples screen shots 

##### zig_imknobs

---

 [zig_imknobs](examples/zig_imknobs/src/main.zig) 

![alt](img/zig_imknobs.png)

##### zig_imtoggle

---

[zig_imtoggle](examples/zig_imtoggle/src/main.zig) 

![alt](img/zig_imtoggle.png)

##### zig_imspinner

---

[zig_imspinner](examples/zig_imspinner/src/main.zig) 

![alt](img/zig_imspinner.gif)

##### zig_imfiledialog

---

[zig_imfiledialog](examples/zig_imfiledialog/src/main.zig) 

![alt](img/zig_imfiledialog.png)

##### zig_imgui_markdown

---

- [x] Work in progress

[zig_imgui_markdown](examples/zig_imgui_markdown/src/main.zig) 

![alt](https://github.com/dinau/cimgui_markdown/raw/main/demo/img/cimgui_markdown.png)

##### zig_iconfontviewer

---

[zig_iconfontviewer](examples/zig_iconfontviewer/src/main.zig) 

- [x] Incremantal search 
- [x] Magnifing glass

![alt](img/zig_iconfontviewer.png)

##### zig_imcolortextedit

---

[zig_imcolortextedit](examples/zig_imcolortextedit/src/main.zig) 

![alt](img/zig_imcolortextedit.png)

##### zig_imguizmo

---

[zig_imguizmo](examples/zig_imguizmo/src/main.zig) 

![alt](img/zig_imguizmo.png)

##### zig_imnodes

---

[zig_imnodes](examples/zig_imnodes/src/main.zig) 

![alt](img/zig_imnodes.png)

##### zig_implot / zig_implot3d

---

[zig_implot](examples/zig_implot/src/main.zig) /  [zig_implot3d](examples/zig_implot3d/src/main.zig) 

[zig_imPlotDemo](examples/zig_imPlotDemo/src/demoAll.zig) written in Zig.

![alt](img/zig_implot3d.gif)  
![alt](img/zig_implot.png)

##### Image load / save

---

|  Language |                                                                             GLFW | Magnifing glass |
|:---------:|---------------------------------------------------------------------------------:|:---------------:|
|  C lang.  |                      [glfw_opengl3_image_load](examples/glfw_opengl3_image_load) |        -        |
|  C lang.  |                      [glfw_opengl3_image_save](examples/glfw_opengl3_image_save) |        -        |
| Zig lang. | [zig_glfw_opengl3_image_load](examples/zig_glfw_opengl3_image_load/src/main.zig) |        v        |

- [x] Image file captured will be saved in current folder.  
- [x] Image format can be selected from `JPEG / PNG / BMP / TGA`.

![alt](img/glfw_opengl3_image_load.png)

##### zig_glfw_opengl3

---

- [x] Basic example

|  Language |                                                                               GLFW |                                                       SDL3 |
|:---------:|-----------------------------------------------------------------------------------:|-----------------------------------------------------------:|
|  C lang.  | [glfw_opengl3](examples/glfw_opengl3), [glfw_opengl3_jp](examples/glfw_opengl3_jp) |                      [sdl3_opengl3](examples/sdl3_opengl3) |
| Zig lang. |                         [zig_glfw_opengl3](examples/zig_glfw_opengl3/src/main.zig) | [zig_sdl3_opengl3](examples/zig_sdl3_opengl3/src/main.zig) |


![alt](img/glfw_opengl3.png) ![alt](img/glfw_opengl3_jp.png)
#### Hiding console window

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

#### SDL libraries

---

https://github.com/libsdl-org/SDL  
https://github.com/libsdl-org/SDL/releases

#### My tools version

---

- gcc.exe (Rev2, Built by MSYS2 project) 15.1.0
- make: GNU Make 4.4.1
- Python 3.12.6
- zig: 0.15.1

#### Similar project ImGui / CImGui

---

| Language             |          | Project                                                                                                                                         |
| -------------------: | :---:    | :----------------------------------------------------------------:                                                                              |
| **Lua**              | Script   | [LuaJITImGui](https://github.com/dinau/luajitImGui)                                                                                             |
| **NeLua**            | Compiler | [NeLuaImGui](https://github.com/dinau/neluaImGui)                                                                                               |
| **Nim**              | Compiler | [ImGuin](https://github.com/dinau/imguin), [Nimgl_test](https://github.com/dinau/nimgl_test), [Nim_implot](https://github.com/dinau/nim_implot) |
| **Python**           | Script   | [DearPyGui for 32bit WindowsOS Binary](https://github.com/dinau/DearPyGui32/tree/win32)                                                         |
| **Ruby**             | Script   | [igRuby_Examples](https://github.com/dinau/igruby_examples)                                                                                     |
| **Zig**, C lang.     | Compiler | [Dear_Bindings_Build](https://github.com/dinau/dear_bindings_build)                                                                             |
| **Zig**              | Compiler | [ImGuinZ](https://github.com/dinau/imguinz)                                                                                                     |


#### SDL game tutorial Platfromer

---

![ald](https://github.com/dinau/nelua-platformer/raw/main/img/platformer-nelua-sdl2.gif)


| Language    |          | SDL         | Project                                                                                                                                               |
| -------------------: | :---:    | :---:       | :----------------------------------------------------------------:                                                                                    |
| **LuaJIT**           | Script   | SDL2        | [LuaJIT-Platformer](https://github.com/dinau/luajit-platformer)
| **Nelua**            | Compiler | SDL2        | [NeLua-Platformer](https://github.com/dinau/nelua-platformer)
| **Nim**              | Compiler | SDL3 / SDL2 | [Nim-Platformer-sdl2](https://github.com/def-/nim-platformer)/ [Nim-Platformer-sdl3](https://github.com/dinau/sdl3_nim/tree/main/examples/platformer) |
| **Ruby**             | Script   | SDL3        | [Ruby-Platformer](https://github.com/dinau/ruby-platformer)                                                                                           |
| **Zig**              | Compiler | SDL3 / SDL2 | [Zig-Platformer](https://github.com/dinau/zig-platformer)                                                                                             |
