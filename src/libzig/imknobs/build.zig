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
        .root_source_file = b.path("../../libc/cimgui-knobs/cimgui-knobs.h"),
        .target = target,
        .optimize = optimize,
    });

    step.addIncludePath(b.path("../../libc/dcimgui"));
    step.addIncludePath(b.path("../../libc/imgui"));
    step.addIncludePath(b.path("../../libc/cimknobs"));
    const mod = step.addModule(mod_name);
    mod.addImport(mod_name, mod);

    mod.addIncludePath(b.path("../../libc/dcimgui"));
    mod.addIncludePath(b.path("../../libc/imgui"));

    mod.addIncludePath(b.path("../../libc/cimgui-knobs"));
    mod.addIncludePath(b.path("../../libc/cimgui-knobs//libs/imgui-knobs"));
    // macro
    mod.addCMacro("IMGUI_ENABLE_WIN32_DEFAULT_IME_FUNCTIONS", "");
    mod.addCMacro("ImDrawIdx", "unsigned int");
    mod.addCMacro("IMGUI_DISABLE_OBSOLETE_FUNCTIONS", "1"); // Nees for ImKnobs

    switch (builtin.target.os.tag) {
        .windows => mod.addCMacro("IMGUI_IMPL_API", "extern \"C\" __declspec(dllexport)"),
        .linux => mod.addCMacro("IMGUI_IMPL_API", "extern \"C\"  "),
        else => {},
    }

    mod.link_libcpp = true;
    mod.addCSourceFiles(.{
        .files = &.{
            "../../libc/cimgui-knobs/cimgui-knobs.cpp",
            "../../libc/cimgui-knobs/libs/imgui-knobs/imgui-knobs.cpp",
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
