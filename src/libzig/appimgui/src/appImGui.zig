const std = @import("std");
const builtin = @import("builtin");
const ig = @import("dcimgui");
const glfw = @import("glfw");
const impl_gl = @import("impl_opengl3");
const impl_glfw = @import("impl_glfw");
const ifa = @import("fonticon");
//const img_ld = @import("loadimage");
const img_icon = @import("loadicon");

//---------------------
// glfw_error_callback
//---------------------
fn glfw_error_callback(err: c_int, description: [*c]const u8) callconv(.C) void {
    std.debug.print("GLFW Error {d}: {s}\n", .{ err, description });
}

pub const Theme = enum {
    light,
    dark,
    classic,
    microsoft,
};

const TImage = struct {
    imageSaveFormatIndex: i32,
};

const TWindow = struct {
    startupPosX: i32,
    startupPosY: i32,
    viewportWidth: i32,
    viewportHeight: i32,
    colBGx: f32,
    colBGy: f32,
    colBGz: f32,
    theme: i32,
};

pub const TIni = struct {
    window: TWindow,
    image: TImage,
};

//--------------
// Window class
//--------------
pub const Window = struct {
    const Self = @This();
    const IMGUI_HAS_DOCK = false; // Docking feature
    handle: ?*glfw.GLFWwindow,
    showWindowDelay: i32, // TODO: Avoid flickering of window at startup
    ini: TIni,
    clearColor: [4]f32,
    var glsl_version_buf: [30]u8 = undefined;

    //-------------
    // createImGui
    //-------------
    const versions = [_][2]u16{ [_]u16{ 4, 6 }, [_]u16{ 4, 5 }, [_]u16{ 4, 4 }, [_]u16{ 4, 3 }, [_]u16{ 4, 2 }, [_]u16{ 4, 1 }, [_]u16{ 4, 0 }, [_]u16{ 3, 3 } };
    pub fn createImGui(w: i32, h: i32, title: [*c]const u8) !Window {
        _ = w;
        _ = h;
        var win: Self = undefined;
        try loadIni(&win);
        // For print()
        const stdout_file = std.io.getStdOut().writer();
        var bw = std.io.bufferedWriter(stdout_file);
        const stdout = bw.writer();

        //-------------------
        // GLFW initializing
        //-------------------
        _ = glfw.glfwSetErrorCallback(glfw_error_callback);
        if (glfw.glfwInit() == 0) {
            try stdout.print("Failed to initialize GLFW: [main.zig]: \n", .{});
            return error.glfwInitFailure;
        }

        //-------------------------
        // Decide GL+GLSL versions
        //-------------------------
        var glsl_version: [:0]u8 = undefined;
        for (versions) |ver| {
            glfw.glfwWindowHint(glfw.GLFW_OPENGL_FORWARD_COMPAT, glfw.GLFW_TRUE);
            glfw.glfwWindowHint(glfw.GLFW_OPENGL_PROFILE, glfw.GLFW_OPENGL_CORE_PROFILE);
            glfw.glfwWindowHint(glfw.GLFW_CONTEXT_VERSION_MAJOR, ver[0]);
            glfw.glfwWindowHint(glfw.GLFW_CONTEXT_VERSION_MINOR, ver[1]);
            //
            glfw.glfwWindowHint(glfw.GLFW_RESIZABLE, glfw.GLFW_TRUE); // Resizable window
            glfw.glfwWindowHint(glfw.GLFW_VISIBLE, glfw.GLFW_FALSE); // Needs this if OpenGL is not initialized !.

            //---------------------------------------------
            // Create GLFW window and activate OpenGL libs
            //---------------------------------------------
            if (glfw.glfwCreateWindow(win.ini.window.viewportWidth, win.ini.window.viewportHeight, title, null, null)) |pointer| {
                win.handle = pointer;
                glsl_version = try std.fmt.bufPrintZ(&glsl_version_buf, "#version {d}", .{ver[0] * 100 + ver[1] * 10});
                try stdout.print("{s} \n", .{glsl_version});
                break;
            }
        } else {
            glfw.glfwTerminate();
            return error.glfwCreateWindowFailure;
        }

        win.showWindowDelay = 2;
        win.clearColor = [_]f32{ win.ini.window.colBGx, win.ini.window.colBGy, win.ini.window.colBGz, 1.0 };

        glfw.glfwMakeContextCurrent(win.handle);

        //---------------------
        // Load title bar icon
        //---------------------
        const TitleBarIconName = "z.png";
        //--------------
        // Get exe path  Refered to: https://stackoverflow.com/questions/77718355/how-do-i-build-a-path-relative-to-the-exe-in-zig
        //--------------
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        defer _ = gpa.deinit();
        const allocator = gpa.allocator();
        const exe_path = try std.fs.selfExePathAlloc(allocator);
        defer allocator.free(exe_path);
        const option_exe_dir = std.fs.path.dirname(exe_path);
        if (option_exe_dir) |exe_dir| {
            var paths = [_][]const u8{ exe_dir, TitleBarIconName };
            const icon_path = try std.fs.path.join(allocator, &paths);
            defer allocator.free(icon_path);
            // Load icon
            img_icon.LoadTitleBarIcon(win.handle, icon_path.ptr);
        }

        glfw.glfwSwapInterval(1); // Enable VSync --- Lower CPU load

        glfw.glfwSetWindowPos(win.handle, win.ini.window.startupPosX, win.ini.window.startupPosY);

        // Setup Dear ImGui context
        if (ig.ImGui_CreateContext(null) == null) {
            return error.ImGuiCreateContextFailure;
        }

        const pio = ig.ImGui_GetIO();
        pio.*.ConfigFlags |= ig.ImGuiConfigFlags_NavEnableKeyboard; // Enable Keyboard Controls
        // pio.*.ConfigFlags |= ig.ImGuiConfigFlags_NavEnableGamepad;    // Enable Gamepad Controls
        // Setup doncking feature --- can't compile well at this moment.
        if (IMGUI_HAS_DOCK) {
            pio.*.ConfigFlags |= ig.ImGuiConfigFlags_DockingEnable; // Enable Docking
            pio.*.ConfigFlags |= ig.ImGuiConfigFlags_ViewportsEnable; // Enable Multi-Viewport / Platform Windows
        }

        //-------------------------------------
        // ImGui GLFW OpenGL backend interface
        //-------------------------------------
        _ = impl_glfw.cImGui_ImplGlfw_InitForOpenGL(@ptrCast(win.handle), true);
        _ = impl_gl.cImGui_ImplOpenGL3_Init();

        _ = setTheme(@enumFromInt(win.ini.window.theme));

        return win;
    }

    //--------
    // render
    //--------
    pub fn render(win: *Window) void {
        const pio = ig.ImGui_GetIO();
        //-----------
        // Rendering
        //-----------
        ig.ImGui_Render();
        glfw.glfwMakeContextCurrent(win.handle);
        glfw.glViewport(0, 0, @intFromFloat(pio.*.DisplaySize.x), @intFromFloat(pio.*.DisplaySize.y));
        glfw.glClearColor(win.ini.window.colBGx, win.ini.window.colBGy, win.ini.window.colBGz, 1.0);
        glfw.glClear(glfw.GL_COLOR_BUFFER_BIT);
        impl_gl.cImGui_ImplOpenGL3_RenderDrawData(@ptrCast(ig.ImGui_GetDrawData()));
        // Docking featrue --- N/A
        if (IMGUI_HAS_DOCK) {
            if (0 != (pio.*.ConfigFlags & ig.ImGuiConfigFlags_ViewportsEnable)) {
                const backup_current_window = glfw.glfwGetCurrentContext();
                ig.ImGui_UpdatePlatformWindows();
                ig.ImGui_RenderPlatformWindowsDefault(null, null);
                glfw.glfwMakeContextCurrent(backup_current_window);
            }
        }
        glfw.glfwSwapBuffers(win.handle);
        if (win.showWindowDelay >= 0) {
            win.showWindowDelay -= 1;
        }
        if (win.showWindowDelay == 0) {
            glfw.glfwShowWindow(win.handle);
        } // Visible main window here at start up
    }

    //-------
    // frame
    //-------
    pub fn frame(win: Window) void {
        // Start the Dear ImGui frame
        _ = win;
        impl_gl.cImGui_ImplOpenGL3_NewFrame();
        impl_glfw.cImGui_ImplGlfw_NewFrame();
        ig.ImGui_NewFrame();
    }

    //--------------
    // destroyImGui
    //--------------
    pub fn destroyImGui(win: *Window) void {
        saveIni(win) catch unreachable;
        impl_gl.cImGui_ImplOpenGL3_Shutdown();
        impl_glfw.cImGui_ImplGlfw_Shutdown();
        ig.ImGui_DestroyContext(null);
        glfw.glfwDestroyWindow(win.handle);
        glfw.glfwTerminate();
    }

    //-------------
    // isIconified
    //-------------
    pub fn isIconified(win: *Window) bool {
       if( 0 != glfw.glfwGetWindowAttrib(win.handle, glfw.GLFW_ICONIFIED)){
           impl_glfw.cImGui_ImplGlfw_Sleep(10);
           return true;
       }
       else {
           return false;
       }
    }

    //-------------
    // shouldClose
    //-------------
    pub fn shouldClose(win: *Window) bool {
        return glfw.glfwWindowShouldClose(win.handle) != 0;
    }

    //------------
    // pollEvents
    //------------
    pub fn pollEvents(win: *Window) void {
        _ = win;
        glfw.glfwPollEvents();
    }
    //------------------
    // Show info window
    //------------------
    pub fn showInfoWindow(win: *Window) void {
        const st = struct {
            var fval: f32 = 0;
        };
        const pio = ig.ImGui_GetIO();
        _ = ig.ImGui_Begin("Info window", null, 0);
        defer ig.ImGui_End();
        ig.ImGui_Text(ifa.ICON_FA_COMMENT ++ " GLFW v");
        ig.ImGui_SameLine();
        ig.ImGui_Text(glfw.glfwGetVersionString());
        ig.ImGui_Text(ifa.ICON_FA_COMMENT ++ " OpenGL v");
        ig.ImGui_SameLine();
        ig.ImGui_Text(glfw.glGetString(glfw.GL_VERSION));
        ig.ImGui_Text(ifa.ICON_FA_CIRCLE_INFO ++ " Dear ImGui v");
        ig.ImGui_SameLine();
        ig.ImGui_Text(ig.ImGui_GetVersion());
        ig.ImGui_Text(ifa.ICON_FA_CIRCLE_INFO ++ " Zig v");
        ig.ImGui_SameLine();
        ig.ImGui_Text(builtin.zig_version_string);
        _ = ig.ImGui_SliderFloat("Float", &st.fval, 0.0, 1.0);
        win.clearColor[0] = win.ini.window.colBGx;
        win.clearColor[1] = win.ini.window.colBGy;
        win.clearColor[2] = win.ini.window.colBGz;
        _ = ig.ImGui_ColorEdit3("Clear color", &win.clearColor, 0);
        win.ini.window.colBGx = win.clearColor[0];
        win.ini.window.colBGy = win.clearColor[1];
        win.ini.window.colBGz = win.clearColor[2];

        ig.ImGui_Text("Application average %.3f ms/frame (%.1f FPS)", 1000.0 / pio.*.Framerate, pio.*.Framerate);
    }
};

//----------
// setTheme
//----------
pub fn setTheme(themeName: Theme) Theme {
    switch (themeName) {
        Theme.light =>     ig.ImGui_StyleColorsLight(null),
        Theme.dark =>      ig.ImGui_StyleColorsDark(null),
        Theme.classic =>   ig.ImGui_StyleColorsClassic(null),
        Theme.microsoft => ig.ImGui_StyleColorsLight(null), //themeMicrosoft(),
    }
    return themeName;
}

const DefaultIni =
    \\{
    \\  "window":{
    \\    "startupPosX":400,
    \\    "startupPosY":80,
    \\    "viewportWidth":1024,
    \\    "viewportHeight":900,
    \\    "colBGx": 0.25,
    \\    "colBGy": 0.65,
    \\    "colBGz": 0.85,
    \\    "theme": 1
    \\  },
    \\  "image":{
    \\    "imageSaveFormatIndex": 0
    \\  }
    \\}
;

//-----------------
// changeExtension
//-----------------
fn changeExtension(filename: []const u8, new_ext: []const u8) ![]const u8 {
    const allocator = std.heap.page_allocator;
    const last_dot = std.mem.lastIndexOfScalar(u8, filename, '.');

    var result: []const u8 = undefined;
    if (last_dot) |dot| {
        result = try std.fmt.allocPrint(allocator, "{s}{s}{s}", .{
            filename[0..dot],
            ".",
            new_ext,
        });
    } else {
        result = try std.fmt.allocPrint(allocator, "{s}.{s}", .{ filename, new_ext });
    }
    return result;
}

//---------
// loadIni
//---------
pub fn loadIni(win: *Window) !void {
    //
    const allocator = std.heap.page_allocator;
    const exe_path = try std.fs.selfExePathAlloc(allocator);
    defer allocator.free(exe_path);

    const filename = try changeExtension(exe_path, "ini");

    var data: TIni = undefined;
    if (std.fs.cwd().openFile(filename, .{})) |file| {
        defer file.close();
        std.debug.print("Read ini: {s}\n", .{filename});

        const file_size = try file.getEndPos();
        const buffer = try allocator.alloc(u8, file_size);
        defer allocator.free(buffer);
        _ = try file.readAll(buffer);

        const parsed_data = try std.json.parseFromSlice(TIni, allocator, buffer, .{});
        defer parsed_data.deinit();
        data = parsed_data.value;
    } else |_| {
        std.debug.print("*.ini file not found: set \"DefaultIni\" values\n", .{});
        const parsed_data = try std.json.parseFromSlice(TIni, allocator, DefaultIni, .{});
        defer parsed_data.deinit();
        data = parsed_data.value;
    }

    // Window pos
    win.ini.window.startupPosX = data.window.startupPosX;
    win.ini.window.startupPosY = data.window.startupPosY;
    if (10 > win.ini.window.startupPosX) {
        win.ini.window.startupPosX = 10;
    }
    if (10 > win.ini.window.startupPosY) {
        win.ini.window.startupPosY = 10;
    }
    if (2048 < win.ini.window.startupPosX) {
        win.ini.window.startupPosX = 10;
    }
    if (2048 < win.ini.window.startupPosY) {
        win.ini.window.startupPosY = 10;
    }

    // Window size
    win.ini.window.viewportWidth = data.window.viewportWidth;
    win.ini.window.viewportHeight = data.window.viewportHeight;
    if (win.ini.window.viewportWidth < 100) {
        win.ini.window.viewportWidth = 100;
    }
    if (win.ini.window.viewportHeight < 100) {
        win.ini.window.viewportHeight = 100;
    }
    if (win.ini.window.viewportWidth > 2048) {
        win.ini.window.viewportWidth = 2048;
    }
    if (win.ini.window.viewportHeight > 2048) {
        win.ini.window.viewportHeight = 2048;
    }

    // Background color
    win.ini.window.colBGx = data.window.colBGx;
    win.ini.window.colBGy = data.window.colBGy;
    win.ini.window.colBGz = data.window.colBGz;

    // Theme
    win.ini.window.theme = data.window.theme;

    // Image index
    win.ini.image.imageSaveFormatIndex = 1;
}

//---------
// saveIni
//---------
pub fn saveIni(win: *Window) !void {
    // Window pos
    glfw.glfwGetWindowPos(win.handle, &win.ini.window.startupPosX, &win.ini.window.startupPosY);

    // Window size
    const ws = ig.ImGui_GetMainViewport().*.WorkSize;
    win.ini.window.viewportWidth = @intFromFloat(ws.x);
    win.ini.window.viewportHeight = @intFromFloat(ws.y);

    // Save to ini file
    const allocator = std.heap.page_allocator;
    const exe_path = try std.fs.selfExePathAlloc(allocator);
    defer allocator.free(exe_path);

    const filename = try changeExtension(exe_path, "ini");
    std.debug.print("Write ini: {s}\n", .{filename});

    var file = try std.fs.cwd().createFile(filename, .{});
    defer file.close();

    var json_string = std.ArrayList(u8).init(allocator);
    try std.json.stringify(win.ini, .{ .whitespace = .indent_2 }, json_string.writer());
    try file.writeAll(json_string.items);
}
