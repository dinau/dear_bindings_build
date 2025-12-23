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
        .root_source_file = b.path("src/impl_guizmo.h"),
        .target = target,
        .optimize = optimize,
    });

    step.defineCMacro("CIMGUI_DEFINE_ENUMS_AND_STRUCTS", "");
    step.addIncludePath(b.path("../../libc/dcimgui"));
    step.addIncludePath(b.path("../../libc/imgui"));
    step.addIncludePath(b.path("../../libc/cimguizmo"));
    step.addIncludePath(b.path("../../libc/cimguizmo/imGuizmo"));
    step.addIncludePath(b.path("src"));
    const mod = step.addModule(mod_name);
    mod.addImport(mod_name, mod);

    mod.addCMacro("imguizmo_NAMESPACE", "imguizmo"); // for imguizmo

    mod.addIncludePath(b.path("../../libc/dcimgui"));
    mod.addIncludePath(b.path("../../libc/imgui"));
    mod.addIncludePath(b.path("../../libc/cimguizmo/imguizmo"));
    mod.addIncludePath(b.path("src"));
    // macro
    //mod.addCMacro("IMGUI_DISABLE_OBSOLETE_FUNCTIONS", "1"); // Important notice : This must not be enabled.

    mod.addCSourceFiles(.{
        .files = &.{
        "../../libc/cimguizmo/cimguizmo.cpp",
        "../../libc/cimguizmo/ImGuizmo/GraphEditor.cpp",
        "../../libc/cimguizmo/ImGuizmo/ImCurveEdit.cpp",
        "../../libc/cimguizmo/ImGuizmo/ImGradient.cpp",
        "../../libc/cimguizmo/ImGuizmo/ImGuizmo.cpp",
        "../../libc/cimguizmo/ImGuizmo/ImSequencer.cpp",
        },
    });
}
