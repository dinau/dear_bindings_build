const std = @import("std");

pub const ig = @cImport({
    @cInclude("GLFW/glfw3.h");
    @cInclude("dcimgui.h");
    @cInclude("dcimgui_impl_glfw.h");
    @cInclude("dcimgui_impl_opengl3.h");
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
    ig.ImGui_StyleColorsClassic(null);
    //ig.ImGui_StyleColorsDark (null);
    //ig.ImGui_StyleColorsLight (null);

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
        if (showWindowDelay >= 0) {
            showWindowDelay -= 1;
        }
        if (showWindowDelay == 0) {
            ig.glfwShowWindow(window);
        } // Visible main window here at start up
    } // while end
} // main end
