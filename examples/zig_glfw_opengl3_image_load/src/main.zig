const std = @import("std");
const builtin = @import("builtin");

pub const ig = @cImport({
    @cInclude("GLFW/glfw3.h");
    @cInclude("dcimgui.h");
    @cInclude("dcimgui_impl_glfw.h");
    @cInclude("dcimgui_impl_opengl3.h");
    @cInclude("loadImage.h");
    @cInclude("saveImage.h");
});
pub const c = @cImport({
    @cInclude("setupFonts.h");
    @cInclude("IconsFontAwesome6.h");
    @cInclude("stb_image.h");
});

const TImgFormat = struct {
    kind: [:0]const u8,
    ext: [:0]const u8,
};
const enKind = enum { jpg, png, bmp, tga };
const ImgFormatTbl = [_]TImgFormat{ TImgFormat{ .kind = "JPEG 90%", .ext = ".jpg" }, TImgFormat{ .kind = "PNG     ", .ext = ".png" }, TImgFormat{ .kind = "BMP     ", .ext = ".bmp" }, TImgFormat{ .kind = "TGA     ", .ext = ".tga" } };

var cbItemIndex: usize = @intFromEnum(enKind.jpg);

// Constants
const SaveImageName = "ImageSaved";
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
    //
    // Load title bar icon
    const IconName = "icon_qr_my_github_red.png";
    const pIconData = ig.LoadTitleBarIcon(window, IconName);
    defer {
        if (pIconData != 0) {
            c.stbi_image_free(pIconData); // free memory for icon
        }
    }

    // Setup Dear ImGui context
    if (ig.ImGui_CreateContext(null) == null) {
        return error.ImGuiCreateContextFailure;
    }
    defer ig.ImGui_DestroyContext(null);

    const pio = ig.ImGui_GetIO();
    pio.*.ConfigFlags |= ig.ImGuiConfigFlags_NavEnableKeyboard; // Enable Keyboard Controls
    //pio.*.ConfigFlags |= ig.ImGuiConfigFlags_NavEnableGamepad;    // Enable Gamepad Controls
    // Setup docking feature --- can't compile well at this moment.
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
    //
    //------------------------
    // Select Dear ImGui style
    //------------------------
    ig.ImGui_StyleColorsClassic(null);
    //ig.ImGui_StyleColorsDark (null);
    //ig.ImGui_StyleColorsLight (null);

    //------------
    // Load image
    //------------
    const ImageName = "himeji-400.jpg";
    var textureId: ig.GLuint = undefined;
    var textureWidth: c_int = 0;
    var textureHeight: c_int = 0;
    _ = ig.LoadTextureFromFile(ImageName, &textureId, &textureWidth, &textureHeight);

    c.setupFonts(); // Setup CJK fonts and Icon fonts

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

        //------------------
        // Show main window
        //------------------
        {
            _ = ig.ImGui_Begin(c.ICON_FA_THUMBS_UP ++ " ImGui: Dear Bindings", null, 0);
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
            ig.ImGui_Text(c.ICON_FA_CIRCLE_INFO ++ " Zig v");
            ig.ImGui_SameLine();
            ig.ImGui_Text(builtin.zig_version_string);

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

            // Save button for capturing window image
            ig.ImGui_PushIDInt(0);
            ig.ImGui_PushStyleColorImVec4(ig.ImGuiCol_Button, ig.ImVec4{ .x = 0.7, .y = 0.7, .z = 0.0, .w = 1.0 });
            ig.ImGui_PushStyleColorImVec4(ig.ImGuiCol_ButtonHovered, ig.ImVec4{ .x = 0.8, .y = 0.8, .z = 0.0, .w = 1.0 });
            ig.ImGui_PushStyleColorImVec4(ig.ImGuiCol_ButtonActive, ig.ImVec4{ .x = 0.9, .y = 0.9, .z = 0.0, .w = 1.0 });
            ig.ImGui_PushStyleColorImVec4(ig.ImGuiCol_Text, ig.ImVec4{ .x = 0.0, .y = 0.0, .z = 0.0, .w = 1.0 });

            // Image save button
            const imageExt = ImgFormatTbl[cbItemIndex].ext;
            var svNameBuf: [2048]u8 = undefined;
            var svBuf: [2048]u8 = undefined;
            const slsName = try std.fmt.bufPrint(&svNameBuf, "{s}_{d}{s}", .{ SaveImageName, counter, imageExt });
            if (ig.ImGui_Button("Save Image")) {
                const wkSize = ig.ImGui_GetMainViewport().*.WorkSize;
                const sx: c_int = @intFromFloat(wkSize.x);
                const sy: c_int = @intFromFloat(wkSize.y);
                _ = c.printf("%s, %d, %d\n", slsName.ptr, sx, sy);
                ig.saveImage(slsName.ptr, 0, 0, sx, sy, 3, 90); // # --- Save Image !
            }
            ig.ImGui_PopStyleColorEx(4);
            ig.ImGui_PopID();

            // Show tooltip help
            const slsBuf = try std.fmt.bufPrint(&svBuf, "Save to {s}", .{slsName});
            setTooltip(slsBuf.ptr);
            counter += 1;

            ig.ImGui_SameLine();
            // ComboBox: Select save image format
            ig.ImGui_SetNextItemWidth(100);
            if (ig.ImGui_BeginCombo("##", ImgFormatTbl[cbItemIndex].kind, 0)) {
                for (ImgFormatTbl, 0..) |_, n| {
                    var is_selected = (cbItemIndex == n);
                    if (ig.ImGui_SelectableBoolPtr(ImgFormatTbl[n].kind, &is_selected, 0)) {
                        if (is_selected) {
                            ig.ImGui_SetItemDefaultFocus();
                        }
                        cbItemIndex = n;
                    }
                }
                ig.ImGui_EndCombo();
            }
            setTooltip("Select image format");

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

        // Show image load window
        {
            _ = ig.ImGui_Begin("Image load test", null, 0);
            defer ig.ImGui_End();
            // Load image
            const size = ig.ImVec2{ .x = @floatFromInt(textureWidth), .y = @floatFromInt(textureHeight) };
            ig.ImGui_SetNextWindowSize(size, ig.ImGuiCond_Always);

            const shortVersion = true;
            const texRef = ig.ImTextureRef{ ._TexData = null, ._TexID = textureId };
            if (shortVersion) {
                ig.ImGui_Image(texRef, size);
            } else { // Long version
                ig.ImGui_ImageEx(texRef, size, ig.ImVec2{ .x = 0, .y = 0 }, ig.ImVec2{ .x = 1, .y = 1 });
            }
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
            if (0 != (pio.*.ConfigFlags & ig.ImGuiConfigFlags_ViewPortsEnable)) {
                const backup_current_window = ig.glfwGetCurrentContext();
                ig.ImGui_UpdatePlatformWindows();
                ig.ImGui_RenderPlatformWindowsDefault();
                ig.glfwMakeContextCurrent(backup_current_window);
            }
        }
        ig.glfwSwapBuffers(window);

        if (showWindowDelay >= 0) {
            showWindowDelay -= 1;
        }
        if (showWindowDelay == 0) {
            ig.glfwShowWindow(window);
        } // Visible main window here at start up
    } // while end
} // main end

//--------------
// setTooltip()
//--------------
fn setTooltip(str: [*c]const u8) void {
    if (ig.ImGui_IsItemHovered(ig.ImGuiHoveredFlags_DelayNormal)) {
        if (ig.ImGui_BeginTooltip()) {
            ig.ImGui_Text(str);
            ig.ImGui_EndTooltip();
        }
    }
}
