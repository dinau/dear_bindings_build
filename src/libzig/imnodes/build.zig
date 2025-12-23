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
        .root_source_file = b.path("src/impl_imnodes.h"),
        .target = target,
        .optimize = optimize,
    });

    step.defineCMacro("CIMGUI_DEFINE_ENUMS_AND_STRUCTS", "");
    step.addIncludePath(b.path("../../libc/dcimgui"));
    step.addIncludePath(b.path("../../libc/imgui"));
    step.addIncludePath(b.path("../../libc/cimnodes"));
    step.addIncludePath(b.path("../../libc/cimnodes/imnodes"));
    step.addIncludePath(b.path("src"));
    const mod = step.addModule(mod_name);
    mod.addImport(mod_name, mod);

    mod.addCMacro("IMNODES_NAMESPACE", "imnodes"); // for imnodes

    mod.addIncludePath(b.path("../../libc/dcimgui"));
    mod.addIncludePath(b.path("../../libc/imgui"));
    mod.addIncludePath(b.path("../../libc/cimnodes/cimnodes"));
    mod.addIncludePath(b.path("src"));
    // macro
    //mod.addCMacro("IMGUI_DISABLE_OBSOLETE_FUNCTIONS", "1");

    mod.addCSourceFiles(.{
        .files = &.{
            "../../libc/cimnodes/cimnodes.cpp",
            "../../libc/cimnodes/imnodes/imnodes.cpp",
        },
    });
}
