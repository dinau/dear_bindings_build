const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod_name = "imguizoomableimage";

    // -------
    // module
    // -------
    const step = b.addTranslateC(.{
        .root_source_file = b.path("src/impl_imguizoomableimage.h"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    step.addIncludePath(b.path("../../libc/cimgui_zoomable_image"));
    step.addIncludePath(b.path("../../libc/dcimgui"));
    step.addIncludePath(b.path("../../libc/imgui"));
    const mod = step.addModule(mod_name);
    mod.link_libcpp = true;
    mod.addIncludePath(b.path("../../libc/cimgui_zoomable_image"));
    mod.addIncludePath(b.path("../../libc/cimgui_zoomable_image/imgui_zoomable_image"));
    mod.addIncludePath(b.path("../../libc/imgui"));
    // Macro
    mod.addCMacro("CIMGUI_API", "extern \"C\"  ");
    mod.addCSourceFiles(.{
        .files = &.{
            "../../libc/cimgui_zoomable_image/cimgui_zoomable_image.cpp",
        },
    });

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = mod_name,
        .root_module = mod,
    });
    b.installArtifact(lib);
}
