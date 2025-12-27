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
    mod.addCSourceFiles(.{
        .files = &.{
            "../../libc/cimgui-knobs/cimgui-knobs.cpp",
            "../../libc/cimgui-knobs/libs/imgui-knobs/imgui-knobs.cpp",
        },
    });
}
