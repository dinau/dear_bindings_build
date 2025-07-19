const std = @import("std");

pub const ig = @cImport({
    @cInclude("GLFW/glfw3.h");
    @cInclude("dcimgui.h");
    @cInclude("dcimgui_internal.h");
    @cInclude("dcimgui_impl_glfw.h");
    @cInclude("dcimgui_impl_opengl3.h");
    // ImGuiFileDialog
    @cInclude("ImGuiFileDialog.h");
});
pub const c = @cImport({
    @cInclude("setupFonts.h");
    @cInclude("IconsFontAwesome6.h");
});

const IMGUI_HAS_DOCK = false; // true: Can't compile at this time.

fn glfw_error_callback(err: c_int, description: [*c]const u8) callconv(.C) void {
    std.debug.print("GLFW Error {d}: {s}\n", .{ err, description });
}

const MainWinWidth: i32 = 1024;
const MainWinHeight: i32 = 800;

//--------
// main()
//--------
pub fn main() !void {
    //-------------
    // For print()
    //-------------
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    //-------------------
    // GLFW initializing
    //-------------------
    _ = ig.glfwSetErrorCallback(glfw_error_callback);
    if (ig.glfwInit() == 0) {
        try stdout.print("Failed to initialize GLFW: [main.zig]: \n", .{});
        try bw.flush(); // don't forget to flush!
        return error.glfwInitFailure;
    }
    defer ig.glfwTerminate();

    //-------------------------
    // Decide GL+GLSL versions
    //-------------------------
    const glsl_version = "#version 130";
    ig.glfwWindowHint(ig.GLFW_OPENGL_FORWARD_COMPAT, ig.GLFW_TRUE);
    ig.glfwWindowHint(ig.GLFW_OPENGL_PROFILE, ig.GLFW_OPENGL_CORE_PROFILE);
    ig.glfwWindowHint(ig.GLFW_CONTEXT_VERSION_MAJOR, 3);
    ig.glfwWindowHint(ig.GLFW_CONTEXT_VERSION_MINOR, 3);
    //
    ig.glfwWindowHint(ig.GLFW_RESIZABLE, ig.GLFW_TRUE); // Resizabe window
    ig.glfwWindowHint(ig.GLFW_VISIBLE, ig.GLFW_FALSE); // Needs this if OpenGL is not initialized !.

    //---------------------------------------------
    // Create GLFW window and activate OpenGL libs
    //---------------------------------------------
    const window = ig.glfwCreateWindow(MainWinWidth, MainWinHeight, "Dear ImGui example", null, null);
    if (window == null) {
        ig.glfwTerminate();
        return error.glfwInitFailure;
    }
    defer ig.glfwDestroyWindow(window);

    ig.glfwMakeContextCurrent(window);

    ig.glfwSwapInterval(1); // Enable VSync --- Lower CPU load

    // Setup Dear ImGui context
    if (ig.ImGui_CreateContext(null) == null) {
        return error.ImGuiCreateContextFailure;
    }
    defer ig.ImGui_DestroyContext(null);

    const pio = ig.ImGui_GetIO();
    pio.*.ConfigFlags |= ig.ImGuiConfigFlags_NavEnableKeyboard; // Enable Keyboard Controls
    //pio.*.ConfigFlags |= ig.ImGuiConfigFlags_NavEnableGamepad;    // Enable Gamepad Controls
    // Setup doncking feature --- can't compile well at this moment.
    if (IMGUI_HAS_DOCK) {
        pio.*.ConfigFlags |= ig.ImGuiConfigFlags_DockingEnable; // Enable Docking
        pio.*.ConfigFlags |= ig.ImGuiConfigFlags_ViewportsEnable; // Enable Multi-Viewport / Platform Windows
    }

    //-------------------------------------
    // ImGui GLFW OpenGL backend interface
    //-------------------------------------
    _ = ig.cImGui_ImplGlfw_InitForOpenGL(window, true);
    defer ig.cImGui_ImplGlfw_Shutdown();
    _ = ig.cImGui_ImplOpenGL3_InitEx(glsl_version);
    defer ig.cImGui_ImplOpenGL3_Shutdown();

    //-------------
    // Global vars
    //-------------
    var showDemoWindow = true;
    var showAnotherWindow = false;
    var fval: f32 = 0.0;
    var counter: i32 = 0;
    // Back ground color
    var clearColor = [_]f32{ 0.25, 0.55, 0.9, 1.0 };
    // Input text buffer
    var sTextInuputBuf = [_:0]u8{0} ** 200;
    var showWindowDelay: i32 = 2; // TODO: Avoid flickering of window at startup

    //------------------------
    // Select Dear ImGui style
    //------------------------
    //ig.ImGui_StyleColorsClassic(null);
    ig.ImGui_StyleColorsDark (null);
    //ig.ImGui_StyleColorsLight (null);

    c.setupFonts(); // Setup CJK fonts and Icon fonts
    //
    //------------------------------
    // Create FileDialog object
    //------------------------------
    const cfd = ig.IGFD_Create();
    defer ig.IGFD_Destroy(cfd);

    setFileStyle(cfd.?);

    var sFilePathName: [2048]u8 = .{0} ** 2048;
    var sFileDirPath: [2048]u8 = .{0} ** 2048;
    var sFilter: [2048]u8 = .{0} ** 2048;
    var sDatas: [2048]u8 = .{0} ** 2048;

    //---------------
    // main loop GUI
    //---------------
    while (ig.glfwWindowShouldClose(window) == 0) {
        ig.glfwPollEvents();

        // Iconify sleep
        if (0 != ig.glfwGetWindowAttrib(window, ig.GLFW_ICONIFIED)) {
            ig.cImGui_ImplGlfw_Sleep(10);
            continue;
        }

        // Start the Dear ImGui frame
        ig.cImGui_ImplOpenGL3_NewFrame();
        ig.cImGui_ImplGlfw_NewFrame();
        ig.ImGui_NewFrame();

        //------------------
        // Show demo window
        //------------------
        if (showDemoWindow) {
            ig.ImGui_ShowDemoWindow(&showDemoWindow);
        }

        //--------------------------
        // Show ImFileDialog window
        //--------------------------
        {
            _ = ig.ImGui_Begin("ImGuiFileDialog: Dear Bindings in Zig  2025/07 " ++ c.ICON_FA_DOG, null, 0);
            defer ig.ImGui_End();

            if (ig.ImGui_ButtonEx("FileOpen", .{ .x = 100, .y = 50 })) {
                //themeGold();
                //------------------------------
                // Trigger FileOpenDialog
                //------------------------------
                var config = ig.IGFD_FileDialog_Config_Get();
                config.path = ".";
                config.flags = ig.ImGuiFileDialogFlags_Modal | ig.ImGuiFileDialogFlags_ShowDevicesButton | ig.ImGuiFileDialogFlags_CaseInsensitiveExtentionFiltering
                // | ImGuiFileDialogFlags_ConfirmOverwrite
                ; // ImGuiFileDialogFlags
                ig.IGFD_OpenDialog(cfd, "filedlg", // dialog key (make it possible to have different treatment reagrding the dialog key
                    c.ICON_FA_FILE ++ " Open a File", // dialog title
                    "all (*){.*},c files(*.c *.h){.c,.h}", // dialog filter syntax : simple => .h,.c,.pp, etc and collections : text1{filter0,filter1,filter2}, text2{filter0,filter1,filter2}, etc..
                    // NULL,                                 // dialog filter syntax : if it wants to select directory then set NULL
                    config); // the file dialog config
            }

            //------------------------------
            // Start display FileOpenDialog
            //------------------------------
            const ioptr = ig.ImGui_GetIO();
            const maxSize = ig.ImVec2{ .x = ioptr.*.DisplaySize.x * 0.8, .y = ioptr.*.DisplaySize.y * 0.8 };
            const minSize = ig.ImVec2{ .x = maxSize.x * 0.25, .y = maxSize.y * 0.25 };

            if (ig.IGFD_DisplayDialog(cfd, "filedlg", ig.ImGuiWindowFlags_NoCollapse, minSize, maxSize)) {
                defer ig.IGFD_CloseDialog(cfd);
                if (ig.IGFD_IsOk(cfd)) { // result ok
                    var cstr = ig.IGFD_GetFilePathName(cfd, ig.IGFD_ResultMode_AddIfNoFileExt);
                    copyToString(&sFilePathName, cstr);
                    cstr = ig.IGFD_GetCurrentPath(cfd);
                    copyToString(&sFileDirPath, cstr);
                    cstr = ig.IGFD_GetCurrentFilter(cfd);
                    copyToString(&sFilter, cstr);
                    // here convert from string because a string was passed as a userDatas, but it can be what you want
                    const cdatas = ig.IGFD_GetUserDatas(cfd);
                    if (null != cdatas) {
                        copyToString(&sDatas, @ptrCast(cdatas));
                    }
                    //struct IGFD_Selection csel = IGFD_GetSelection(cfd, IGFD_ResultMode_KeepInputFile); // multi selection
                    //printf("Selection :\n");
                    //for (int i = 0; i < (int)csel.count; i++) {
                    //  printf("(%i) FileName %s => path %s\n", i, csel.table[i].fileName, csel.table[i].filePathName);
                    //}
                    //// action
                    //ig.IGFD_Selection_DestroyContent(&csel);
                }
                //setTheme(0);
            }
            // End FileOpenDialog
            ig.ImGui_Text("Selected file = %s", &sFilePathName);
            ig.ImGui_Text("Dir           = %s", &sFileDirPath);
            ig.ImGui_Text("Filter        = %s", &sFilter);
            ig.ImGui_Text("Datas         = %s", &sDatas);
        }

        //------------------
        // Show main window
        //------------------
        {
            _ = ig.ImGui_Begin("ImGui: Dear Bindings " ++ c.ICON_FA_THUMBS_UP, null, 0);
            defer ig.ImGui_End();
            ig.ImGui_Text(c.ICON_FA_COMMENT ++ " GLFW v");
            ig.ImGui_SameLine();
            ig.ImGui_Text(ig.glfwGetVersionString());
            ig.ImGui_Text(c.ICON_FA_COMMENT ++ " OpenGL v");
            ig.ImGui_SameLine();
            ig.ImGui_Text(ig.glGetString(ig.GL_VERSION));
            ig.ImGui_Text(c.ICON_FA_CIRCLE_INFO ++ " Dear ImGui v");
            ig.ImGui_SameLine();
            ig.ImGui_Text(ig.IMGUI_VERSION);

            ig.ImGui_Spacing();
            _ = ig.ImGui_InputTextWithHint("InputText", "Input text here", &sTextInuputBuf, sTextInuputBuf.len, 0);
            ig.ImGui_Text("Input result:");
            ig.ImGui_SameLine();
            ig.ImGui_Text(&sTextInuputBuf);

            ig.ImGui_Spacing();
            _ = ig.ImGui_Checkbox("Demo Window", &showDemoWindow);
            _ = ig.ImGui_Checkbox("Another Window", &showAnotherWindow);

            _ = ig.ImGui_SliderFloat("Float", &fval, 0.0, 1.0);
            _ = ig.ImGui_ColorEdit3("Clear color", &clearColor, 0);

            if (ig.ImGui_Button("Button")) counter += 1;
            ig.ImGui_SameLine();
            ig.ImGui_Text("Counter = %d", counter);
            ig.ImGui_Text("Application average %.3f ms/frame (%.1f FPS)", 1000.0 / pio.*.Framerate, pio.*.Framerate);
            // Show icon fonts
            ig.ImGui_SeparatorText(c.ICON_FA_WRENCH ++ " Icon font test ");
            ig.ImGui_Text(c.ICON_FA_TRASH_CAN ++ " Trash");

            ig.ImGui_Spacing();
            ig.ImGui_Text(c.ICON_FA_MAGNIFYING_GLASS_PLUS ++ " " ++ c.ICON_FA_POWER_OFF ++ " " ++ c.ICON_FA_MICROPHONE ++ " " ++ c.ICON_FA_MICROCHIP ++ " " ++ c.ICON_FA_VOLUME_HIGH ++ " " ++ c.ICON_FA_SCISSORS ++ " " ++ c.ICON_FA_SCREWDRIVER_WRENCH ++ " " ++ c.ICON_FA_BLOG);
        }

        //---------------------
        // Show another window
        //---------------------
        if (showAnotherWindow) {
            _ = ig.ImGui_Begin("Another Window", &showAnotherWindow, 0);
            defer ig.ImGui_End();
            ig.ImGui_Text("Hello from another window!");
            if (ig.ImGui_Button("Close Me")) showAnotherWindow = false;
        }

        //-----------
        // End procs
        //-----------
        // Rendering
        ig.ImGui_Render();
        ig.glfwMakeContextCurrent(window);
        ig.glViewport(0, 0, @intFromFloat(pio.*.DisplaySize.x), @intFromFloat(pio.*.DisplaySize.y));
        ig.glClearColor(clearColor[0], clearColor[1], clearColor[2], clearColor[3]);
        ig.glClear(ig.GL_COLOR_BUFFER_BIT);
        ig.cImGui_ImplOpenGL3_RenderDrawData(ig.ImGui_GetDrawData());
        // Docking featrue --- N/A
        if (IMGUI_HAS_DOCK) {
            if (pio.*.ConfigFlags & ig.ImGuiConfigFlags_ViewPortsEnable) {
                const backup_current_window = ig.glfwGetCurrentContext();
                ig.ImGui_UpdatePlatformWindows();
                ig.ImGui_RenderPlatformWindowsDefault();
                ig.glfwMakeContextCurrent(backup_current_window);
            }
        }
        ig.glfwSwapBuffers(window);

        if (showWindowDelay >= 0) { showWindowDelay -= 1; }
        if (showWindowDelay == 0) { ig.glfwShowWindow(window); } // Visible main window here at start up
    } // while end
} // main end

//-----------------
//--- setFileStyle
//-----------------
fn setFileStyle(cfd: *ig.ImGuiFileDialog) void {
    //const clGreen      = ig.ImVec4{.x = 0,    .y = 1,             .z = 0,   .w = 1};
    const clMDseagreen = ig.ImVec4{ .x = 60.0 / 255.0, .y = 179.0 / 255.0, .z = 113.0 / 255.0, .w = 1 };

    const clYellow = ig.ImVec4{ .x = 1, .y = 1, .z = 0, .w = 1 };
    const clOrange = ig.ImVec4{ .x = 1, .y = 165.0 / 255.0, .z = 0, .w = 1 };

    const clWhite2 = ig.ImVec4{ .x = 0.98, .y = 0.98, .z = 1, .w = 1 };
    const clWhite = ig.ImVec4{ .x = 1, .y = 0, .z = 1, .w = 1 };

    //const  clPurple  = ig.ImVec4{.x = 1,  .y =  51.0/255.0,    .z = 1, .w = 1};
    //const  clPurple2 = ig.ImVec4{.x = 1,  .y = 161.0/255.0,    .z = 1, .w = 1};

    const clCyan = ig.ImVec4{ .x = 0, .y = 1, .z = 1, .w = 1 };
    const clSkyblue = ig.ImVec4{ .x = 135.0 / 255.0, .y = 206.0 / 255.0, .z = 235.0 / 255.0, .w = 1 };
    const clIndigo = ig.ImVec4{ .x = 75.0 / 255.0, .y = 0, .z = 130.0 / 255.0, .w = 1 };
    const clMoccasin = ig.ImVec4{ .x = 1, .y = 228.0 / 255.0, .z = 181.0 / 255.0, .w = 1 };
    //const  clRosybrown = ig.ImVec4{.x = 188.0/255.0, .y = 143.0/255.0, .z =  143.0/255.0,.w = 1};

    //const clSteelblue = ig.ImVec4{.x = 70.0/255.0,   .y = 130.0/255.0, .z = 180.0/255.0, .w = 1};

    const pFont = ig.ImGui_GetDefaultFont();
    const byExt = ig.IGFD_FileStyleByExtention;

    ig.IGFD_SetFileStyle(cfd, byExt, ".bat", clCyan, c.ICON_FA_PERSON_RUNNING, pFont);
    ig.IGFD_SetFileStyle(cfd, byExt, ".pdb", clYellow, c.ICON_FA_FILE, pFont);
    ig.IGFD_SetFileStyle(cfd, byExt, ".exe", clCyan, c.ICON_FA_PLANE, pFont);
    ig.IGFD_SetFileStyle(cfd, byExt, ".EXE", clCyan, c.ICON_FA_PLANE, pFont);
    ig.IGFD_SetFileStyle(cfd, byExt, ".nim", clSkyblue, c.ICON_FA_N, pFont);
    ig.IGFD_SetFileStyle(cfd, byExt, ".nelua", clSkyblue, c.ICON_FA_FILE, pFont);
    ig.IGFD_SetFileStyle(cfd, byExt, ".lua", clIndigo, c.ICON_FA_FILE, pFont);
    ig.IGFD_SetFileStyle(cfd, byExt, ".zig", clSkyblue, c.ICON_FA_FILE, pFont);
    ig.IGFD_SetFileStyle(cfd, byExt, ".c", clMDseagreen, c.ICON_FA_FILE, pFont);
    ig.IGFD_SetFileStyle(cfd, byExt, ".cpp", clMDseagreen, c.ICON_FA_FILE, pFont);
    ig.IGFD_SetFileStyle(cfd, byExt, ".h", clYellow, c.ICON_FA_FILE, pFont);
    ig.IGFD_SetFileStyle(cfd, byExt, ".d", clWhite2, c.ICON_FA_FILE, pFont);
    ig.IGFD_SetFileStyle(cfd, byExt, ".txt", clWhite2, c.ICON_FA_FILE_LINES, pFont);
    ig.IGFD_SetFileStyle(cfd, byExt, ".TXT", clWhite2, c.ICON_FA_FILE_LINES, pFont);
    ig.IGFD_SetFileStyle(cfd, byExt, ".ini", clWhite2, c.ICON_FA_BAHAI, pFont);
    ig.IGFD_SetFileStyle(cfd, byExt, ".md", clMoccasin, c.ICON_FA_PEN_TO_SQUARE, pFont);
    ig.IGFD_SetFileStyle(cfd, byExt, ".html", clMoccasin, c.ICON_FA_GLOBE, pFont);
    ig.IGFD_SetFileStyle(cfd, byExt, ".gitignore", clWhite2, c.ICON_FA_BAHAI, pFont);
    ig.IGFD_SetFileStyle(cfd, byExt, ".gitmodules", clWhite2, c.ICON_FA_BAHAI, pFont);
    ig.IGFD_SetFileStyle(cfd, byExt, ".o", clWhite2, c.ICON_FA_SEEDLING, pFont);
    ig.IGFD_SetFileStyle(cfd, byExt, ".a", clWhite2, c.ICON_FA_BAHAI, pFont);
    ig.IGFD_SetFileStyle(cfd, byExt, ".rc", clWhite2, c.ICON_FA_BAHAI, pFont);
    ig.IGFD_SetFileStyle(cfd, byExt, ".res", clWhite2, c.ICON_FA_BAHAI, pFont);
    ig.IGFD_SetFileStyle(cfd, byExt, ".ico", clWhite, c.ICON_FA_IMAGE, pFont);
    ig.IGFD_SetFileStyle(cfd, byExt, ".png", clWhite, c.ICON_FA_IMAGE, pFont);
    ig.IGFD_SetFileStyle(cfd, byExt, ".jpg", clWhite, c.ICON_FA_IMAGE, pFont);
    ig.IGFD_SetFileStyle(cfd, byExt, ".mp3", clWhite, c.ICON_FA_MUSIC, pFont);
    ig.IGFD_SetFileStyle(cfd, byExt, ".MP3", clWhite, c.ICON_FA_MUSIC, pFont);
    ig.IGFD_SetFileStyle(cfd, byExt, ".mp4", clWhite, c.ICON_FA_FILM, pFont);
    ig.IGFD_SetFileStyle(cfd, byExt, ".MP4", clWhite, c.ICON_FA_FILM, pFont);
    ig.IGFD_SetFileStyle(cfd, byExt, ".zip", clWhite, c.ICON_FA_FILE_ZIPPER, pFont);
    ig.IGFD_SetFileStyle(cfd, byExt, ".cmake", clYellow, c.ICON_FA_GEARS, pFont);
    ig.IGFD_SetFileStyle(cfd, byExt, ".mak", clWhite, c.ICON_FA_GEARS, pFont);
    ig.IGFD_SetFileStyle(cfd, byExt, ".mk", clWhite, c.ICON_FA_GEARS, pFont);
    ig.IGFD_SetFileStyle(cfd, byExt, ".dll", clWhite, c.ICON_FA_SNOWFLAKE, pFont);
    ig.IGFD_SetFileStyle(cfd, byExt, ".sys", clWhite, c.ICON_FA_SNOWMAN, pFont);
    //-- For folder
    ig.IGFD_SetFileStyle(cfd, ig.IGFD_FileStyleByTypeDir, null, clOrange, c.ICON_FA_FOLDER, pFont);
    //-- Regex TODO
    //--ig.IGFD_SetFileStyle(cfd, byExt , "(.+[.].+)",   clWhite2,     ICON_FA_FILE,           pFont)
}

//-----------------
//--- copyToString
//-----------------
fn copyToString(sBuff: []u8, cstr: [*:0]const u8) void {
    const len = std.mem.len(cstr);
    std.mem.copyForwards(u8, sBuff[0..len], cstr[0..len]);
    sBuff[len] = 0;
}
