const std = @import("std");
const builtin = @import("builtin");
const ig = @import("dcimgui");
const ifa = @import("fonticon");
const is_devel_api = builtin.zig_version.minor >= 16;
const io = if (is_devel_api) std.Io.Threaded.global_single_threaded.io() else undefined;

const MAX_PATH = 2048;
const IconFontPath = "resources/fonticon/fa6/fa-solid-900.ttf";

const WinFontNameTbl = [_][]const u8{
    "meiryo.ttc", // Windows 7,8
    "YuGothM.ttc", // Windows 10
    "segoeui.ttf", // English standard
};

const LinuxFontNameTbl = [_][]const u8{
    // For Linux Mint 22 (Ubuntu/Debian family ok ?)
    "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc", // JP
    "/usr/share/fonts/opentype/ipafont-gothic/ipag.ttf", // Debian
    "/usr/share/fonts/opentype/ipafont-gothic/ipam.ttf", // Debian
    "/usr/share/fonts/truetype/liberation/LiberationMono-Regular.ttf", // Linux Mint English
    "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf", // English region standard font
};

// Windows API declarations for file existence check
const INVALID_FILE_ATTRIBUTES: u32 = 0xFFFFFFFF;
extern "kernel32" fn GetFileAttributesA(lpFileName: [*:0]const u8) callconv(.c) u32;

/// Check if file exists
fn existsFile(path: []const u8) bool {
    if (is_devel_api) {
        // Zig 0.16.0-dev: Use Windows API on Windows, simple access check elsewhere
        if (builtin.os.tag == .windows) {
            var path_buf: [std.fs.max_path_bytes:0]u8 = undefined;
            if (path.len >= path_buf.len) return false;
            @memcpy(path_buf[0..path.len], path);
            path_buf[path.len] = 0;

            const attrs = GetFileAttributesA(&path_buf);
            return attrs != INVALID_FILE_ATTRIBUTES;
        } else {
            // For non-Windows platforms, use access syscall
            var path_buf: [std.fs.max_path_bytes:0]u8 = undefined;
            if (path.len >= path_buf.len) return false;
            @memcpy(path_buf[0..path.len], path);
            path_buf[path.len] = 0;

            const result = std.c.access(&path_buf, std.c.F_OK);
            return result == 0;
        }
    } else {
        // Zig 0.15.2: Use std.fs.cwd()
        const cwd_dir = std.fs.cwd();
        const file = cwd_dir.openFile(path, .{}) catch return false;
        defer file.close();
        return true;
    }
}

/// Get Windows font path
fn getWinFontPath(buf: []u8, font_name: []const u8) ?[]const u8 {
    const win_dir = if (is_devel_api) blk: {
        // Zig 0.16.0-dev: Use std.c.getenv
        const c_str = std.c.getenv("windir") orelse return null;
        break :blk std.mem.span(c_str);
    } else blk: {
        // Zig 0.15.2: Use std.process.getEnvVarOwned
        const wd = std.process.getEnvVarOwned(
            std.heap.page_allocator,
            "windir",
        ) catch return null;
        defer std.heap.page_allocator.free(wd);

        // Copy result to buffer
        const result = std.fmt.bufPrint(
            buf,
            "{s}\\Fonts\\{s}",
            .{ wd, font_name },
        ) catch return null;

        break :blk result;
    };

    // For Zig 0.16.0-dev, create the result here
    if (is_devel_api) {
        const result = std.fmt.bufPrint(
            buf,
            "{s}\\Fonts\\{s}",
            .{ win_dir, font_name },
        ) catch return null;

        return result;
    } else {
        // For Zig 0.15.2, result is already created
        return win_dir;
    }
}

/// Convert point to pixel
fn point2px(point: f32) f32 {
    return (point * 96.0) / 72.0;
}

var config: *ig.ImFontConfig = undefined;

/// Create ImFontConfig
fn ImFontConfig_create() *ig.ImFontConfig {
    const allocator = std.heap.page_allocator;
    const cfg = allocator.create(ig.ImFontConfig) catch @panic("Failed to allocate ImFontConfig");

    @memset(std.mem.asBytes(cfg), 0);
    cfg.FontDataOwnedByAtlas = true;
    cfg.FontNo = 0;
    cfg.OversampleH = 3;
    cfg.OversampleV = 1;
    cfg.PixelSnapH = false;
    cfg.GlyphMaxAdvanceX = std.math.floatMax(f32);
    cfg.RasterizerMultiply = 1.0;
    cfg.RasterizerDensity = 1.0;
    cfg.MergeMode = false;
    cfg.EllipsisChar = @as(ig.ImWchar, @bitCast(@as(u16, 0xFFFF)));

    return cfg;
}

const ranges_icon_fonts = [_]ig.ImWchar{
    @as(ig.ImWchar, ifa.ICON_MIN_FA),
    @as(ig.ImWchar, ifa.ICON_MAX_FA),
    0,
};

/// Setup fonts
pub export fn setupFonts() ?*ig.ImFont {
    const pio = ig.ImGui_GetIO();
    var font: ?*ig.ImFont = null;

    var buf: [MAX_PATH]u8 = undefined;
    var path_buf: [MAX_PATH:0]u8 = undefined; // Create null-terminated string for C API

    // Try Windows fonts
    for (WinFontNameTbl) |font_name| {
        if (getWinFontPath(&buf, font_name)) |font_path| {
            @memcpy(path_buf[0..font_path.len], font_path);
            path_buf[font_path.len] = 0;

            if (existsFile(font_path)) {
                font = ig.ImFontAtlas_AddFontFromFileTTF(
                    pio.*.Fonts,
                    &path_buf,
                    point2px(14.5),
                    null,
                    null,
                );
                std.debug.print("\n==== Found FontPath: [{s}]\n", .{font_path});
                break;
            }
        }
    }

    // Try Linux fonts if Windows fonts not found
    if (font == null) {
        for (LinuxFontNameTbl) |font_path| {
            if (existsFile(font_path)) {
                @memcpy(path_buf[0..font_path.len], font_path);
                path_buf[font_path.len] = 0;

                font = ig.ImFontAtlas_AddFontFromFileTTF(
                    pio.*.Fonts,
                    &path_buf,
                    point2px(13.0),
                    null,
                    null,
                );
                std.debug.print("\n==== Found FontPath: [{s}]\n", .{font_path});
                break;
            }
        }
    }

    // Use default font if no font found
    if (font == null) {
        std.debug.print("\n==== Error!: Font loading failed\n", .{});
        std.debug.print("\n==== Default has been set.\n", .{});
        _ = ig.ImFontAtlas_AddFontDefault(pio.*.Fonts, null);
    }

    // Merge IconFont
    config = ImFontConfig_create();
    config.MergeMode = true;
    if (existsFile(IconFontPath)) {
        var icon_path_buf: [IconFontPath.len:0]u8 = undefined;
        @memcpy(&icon_path_buf, IconFontPath);
        icon_path_buf[IconFontPath.len] = 0;

        return ig.ImFontAtlas_AddFontFromFileTTF(
            pio.*.Fonts,
            &icon_path_buf,
            point2px(11.0),
            config,
            &ranges_icon_fonts,
        );
    } else {
        std.debug.print("\n==== Error!: Font not found [ {s} ]\n", .{IconFontPath});
        return null;
    }
}
