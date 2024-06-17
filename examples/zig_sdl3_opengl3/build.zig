// Used zig-0.12.0 (2024/06)
//
const std = @import("std");
const builtin = @import("builtin");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

//    const lib = b.addStaticLibrary(.{
//        .name = "zig_sdl3_opengl3_image_load",
//        // In this case the main source file is merely a path, however, in more
//        // complicated build scripts, this could be a generated file.
//        .root_source_file = b.path("src/root.zig"),
//        .target = target,
//        .optimize = optimize,
//    });

    // This declares intent for the library to be installed into the standard
    // location when the user invokes the "install" step (the default step when
    // running `zig build`).
//    b.installArtifact(lib);

    const exe = b.addExecutable(.{
        .name = "zig_sdl3_opengl3",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    //----------------------------------
    // Detect 32bit or 64bit Winddws OS
    //----------------------------------
    var sBuf: [2048]u8 = undefined;
    const sdl3_Base = "../../libs/sdl/sdl3";
    var sArc:[]const u8 = "64";
    if(builtin.cpu.arch == std.Target.Cpu.Arch.x86){
      sArc = "32";
    }
    //const sdl3_rel_date = "2024-06-02";
    const sdl3_rel_date = "2024-06-16";
    const sdl3_path = std.fmt.bufPrint(&sBuf, "{s}/{s}/SDL3-{s}/SDL3", .{sdl3_Base,sArc,sdl3_rel_date}) catch unreachable;
    //---------------
    // Include paths
    //---------------
    exe.addIncludePath(b.path(b.pathJoin(&.{sdl3_path, "include"})));
    //
    exe.addIncludePath(b.path("src"));
    exe.addIncludePath(b.path("../utils"));
    exe.addIncludePath(b.path("../utils/fonticon"));
    exe.addIncludePath(b.path("../libs/cimgui"));
    exe.addIncludePath(b.path("../../libs/imgui"));
    exe.addIncludePath(b.path("../../libs/stb"));
    exe.addIncludePath(b.path("../../libs/imgui/backends"));
    //--------------------------------
    // Define macro for C/C++ sources
    //--------------------------------
    exe.root_module.addCMacro("IMGUI_ENABLE_WIN32_DEFAULT_IME_FUNCTIONS", "");
    exe.root_module.addCMacro("ImDrawIdx", "unsigned int");
    exe.root_module.addCMacro("CIMGUI_USE_sdl3", "");
    //---------------
    // Sources C/C++
    //---------------
    exe.addCSourceFiles(.{
      .files = &.{
        // ImGui main
        "../../libs/imgui/imgui.cpp",
        "../../libs/imgui/imgui_tables.cpp",
        "../../libs/imgui/imgui_demo.cpp",
        "../../libs/imgui/imgui_widgets.cpp",
        "../../libs/imgui/imgui_draw.cpp",
        // CImGui main
        "../libs/cimgui/cimgui.cpp",
        // ImGui sdl3 and OpenGL interface
        "../../libs/imgui/backends/imgui_impl_opengl3.cpp",
        "../../libs/imgui/backends/imgui_impl_sdl3.cpp",
        // CImGui sdl3 and OpenGL interface
        "../libs/cimgui/cimgui_impl_sdl3.cpp",
        "../libs/cimgui/cimgui_impl_opengl3.cpp",
        // CImGui SDL interface
        //"../libs/cimgui/cimgui_impl_sdl3.cpp",
        //"../libs/cimgui/cimgui_impl_sdl3.cpp",
        // utils folder
        "../utils/setupFonts.c",
        "../utils/loadImage.c",
        "../utils/saveImage.c",
        "../utils/utils.c",
      },
      .flags = &.{
      },
    });
    //---------------
    // Libs
    //---------------
    exe.linkSystemLibrary("gdi32");
    exe.linkSystemLibrary("imm32");
    exe.linkSystemLibrary("advapi32");
    exe.linkSystemLibrary("comdlg32");
    exe.linkSystemLibrary("dinput8");
    exe.linkSystemLibrary("dxerr8");
    exe.linkSystemLibrary("dxguid");
    exe.linkSystemLibrary("gdi32");
    exe.linkSystemLibrary("hid");
    exe.linkSystemLibrary("kernel32");
    exe.linkSystemLibrary("ole32");
    exe.linkSystemLibrary("oleaut32");
    exe.linkSystemLibrary("setupapi");
    exe.linkSystemLibrary("shell32");
    exe.linkSystemLibrary("user32");
    exe.linkSystemLibrary("uuid");
    exe.linkSystemLibrary("version");
    exe.linkSystemLibrary("winmm");
    exe.linkSystemLibrary("winspool");
    exe.linkSystemLibrary("ws2_32");
    exe.linkSystemLibrary("opengl32");
    exe.linkSystemLibrary("shell32");
    exe.linkSystemLibrary("user32");
    // sdl3
    //exe.addLibraryPath(b.path(b.pathJoin(&.{sdl3_path, "lib-mingw-64"})));
    //exe.linkSystemLibrary("sdl3");      // For static link
    // Static link
    exe.addObjectFile(b.path(b.pathJoin(&.{sdl3_path, "lib","SDL3.lib"})));
    // Dynamic link
    //exe.addObjectFile(b.path(b.pathJoin(&.{sdl3_path, "lib","libsdl3dll.a"})));
    //exe.linkSystemLibrary("sdl3dll"); // For dynamic link
    // System
    exe.linkLibC();
    exe.linkLibCpp();
    //exe.subsystem = .Windows;  // Hide console window

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(exe);

    const resBin      = [_][]const u8{ "imgui.ini"};
    const resUtils    = [_][]const u8{ "fonticon/fa6/fa-solid-900.ttf"
                                     , "fonticon/fa6/LICENSE.txt"};
    const resSDL3_rsc = [_][]const u8{ "SDL3.dll"};

    inline for(resBin)|file|{
      const res = b.addInstallFile(b.path(file),"bin/" ++ file);
      b.getInstallStep().dependOn(&res.step);
    }
    inline for(resUtils)|file|{
      const res = b.addInstallFile(b.path("../utils/" ++ file),"utils/" ++ file);
      b.getInstallStep().dependOn(&res.step);
    }
    inline for(resSDL3_rsc)|file|{
      const res = b.addInstallFile(b.path(b.pathJoin(&.{sdl3_path, "/bin/", file})),"bin/" ++ file);
      b.getInstallStep().dependOn(&res.step);
    }
    //
    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}
