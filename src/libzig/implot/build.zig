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
        .root_source_file = b.path("src/impl_implot.h"),
        .target = target,
        .optimize = optimize,
    });

    step.addIncludePath(b.path("./src"));
    step.addIncludePath(b.path("../../libc/dcimgui"));
    step.addIncludePath(b.path("../../libc/imgui"));
    step.addIncludePath(b.path("../../libc/cimplot"));
    step.defineCMacro("CIMGUI_DEFINE_ENUMS_AND_STRUCTS", "");
    //
    const mod = step.addModule(mod_name);
    mod.addImport(mod_name, mod);
    mod.addIncludePath(b.path("../../libc/dcimgui/imgui"));
    mod.addIncludePath(b.path("../../libc/dcimgui"));
    mod.addIncludePath(b.path("../../libc/imgui"));
    mod.addIncludePath(b.path("../../libc/cimplot"));
    mod.addIncludePath(b.path("../../libc/cimplot/implot"));
    mod.addIncludePath(b.path("./src"));
    // macro
    mod.addCMacro("ImDrawIdx", "unsigned int");
    //mod.addCMacro("IMGUI_DISABLE_OBSOLETE_FUNCTIONS", "1");

    mod.addCSourceFiles(.{
        .files = &.{
            "../../libc/cimplot/cimplot.cpp",
            "../../libc/cimplot/implot/implot.cpp",
            "../../libc/cimplot/implot/implot_demo.cpp",
            "../../libc/cimplot/implot/implot_items.cpp",
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
