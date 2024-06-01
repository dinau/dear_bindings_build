# dear_bindings_build
ImGui: Simple dear_bindings build project

Now highly work in progress.


## Prerequisite

---

- Windows10 OS
- GCC or Clang compiler
- Pyhton
- make

## Build and run

---

```sh
git clone --recurse-submodules https://github.com/dinau/dear_bindings_build
cd dear_bindings_build/examples/glfw_opengl
make run
```

## Regenarate ImGui bindings

---

```sh
pwd 
glfw_opengl
make genbind
```

## My tools version

---

- clang version 18.1.6
- cmake version 3.28.0-rc2
- gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
- git version 2.41.0.windows.3
- make: GNU Make 4.2.1
- Python 3.12.3
- zig: 0.12.0
