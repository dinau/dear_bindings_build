const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const allocator = b.allocator;
    const current_dir_abs = b.build_root.handle.realpathAlloc(allocator, ".") catch unreachable;
    defer allocator.free(current_dir_abs);
    const mod_name = std.fs.path.basename(current_dir_abs);

    // -------
    // module
    // -------
    const step = b.addTranslateC(.{
        .root_source_file = b.path("src/toggle.h"),
        .target = target,
        .optimize = optimize,
    });

    step.addIncludePath(b.path("../../libc/dcimgui"));
    step.addIncludePath(b.path("../../libc/imgui"));
    step.addIncludePath(b.path("../../libc/cimgui_toggle"));
    const mod = step.addModule(mod_name);
    mod.addImport(mod_name, mod);
    mod.addIncludePath(b.path("../../libc/dcimgui/imgui"));
    mod.addIncludePath(b.path("../../libc/dcimgui"));
    mod.addIncludePath(b.path("../../libc/imgui"));
    mod.addIncludePath(b.path("../../libc/cimgui_toggle/libs/imgui_toggle"));
    // macro
    mod.addCMacro("IMGUI_ENABLE_WIN32_DEFAULT_IME_FUNCTIONS", "");
    mod.addCMacro("ImDrawIdx", "unsigned int");
    mod.addCMacro("IMGUI_DISABLE_OBSOLETE_FUNCTIONS", "1");

    switch (builtin.target.os.tag) {
        .windows => mod.addCMacro("IMGUI_IMPL_API", "extern \"C\" __declspec(dllexport)"),
        .linux => mod.addCMacro("IMGUI_IMPL_API", "extern \"C\"  "),
        else => {},
    }
    mod.addCSourceFiles(.{
        .files = &.{
            "../../libc/cimgui_toggle/libs/imgui_toggle/imgui_toggle.cpp",
            "../../libc/cimgui_toggle/libs/imgui_toggle/imgui_toggle_presets.cpp",
            "../../libc/cimgui_toggle/libs/imgui_toggle/imgui_toggle_renderer.cpp",
            "../../libc/cimgui_toggle/libs/imgui_toggle/imgui_toggle_palette.cpp",
            // CImGui-Toggle
            "../../libc/cimgui_toggle/cimgui_toggle.cpp",
            "../../libc/cimgui_toggle/cimgui_offset_rect.cpp",
            "../../libc/cimgui_toggle/cimgui_toggle_presets.cpp",
        },
    });

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = mod_name,
        .root_module = mod,
    });
    b.installArtifact(lib);
    //std.debug.print("{s} module\n",.{mod_name});
}
