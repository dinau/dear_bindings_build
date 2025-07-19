const std = @import("std");
const builtin = @import("builtin");

pub const ig = @cImport({
    @cInclude("dcimgui.h");
    @cInclude("dcimgui_impl_sdl3.h");
    @cInclude("dcimgui_impl_opengl3.h");
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_opengl.h");
    @cInclude("SDL3/SDL_mouse.h");
});
pub const c = @cImport({
    @cInclude("setupFonts.h");
    @cInclude("IconsFontAwesome6.h");
});

const IMGUI_HAS_DOCK = false; // true: Can't compile at this time.

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

    // Setup SDL
    if (!ig.SDL_Init(ig.SDL_INIT_VIDEO | ig.SDL_INIT_GAMEPAD)) {
        try stdout.print("Error: {s}\n", .{ig.SDL_GetError()});
        return error.SDL_init;
    }
    defer ig.SDL_Quit();

    //-------------------------
    // Decide GL+GLSL versions
    //-------------------------
    const glsl_version = "#version 130";
    _ = ig.SDL_GL_SetAttribute(ig.SDL_GL_CONTEXT_FLAGS, 0);
    _ = ig.SDL_GL_SetAttribute(ig.SDL_GL_CONTEXT_PROFILE_MASK, ig.SDL_GL_CONTEXT_PROFILE_CORE);
    _ = ig.SDL_GL_SetAttribute(ig.SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    _ = ig.SDL_GL_SetAttribute(ig.SDL_GL_CONTEXT_MINOR_VERSION, 3);

    //_ = ig.SDL_SetHint(ig.SDL_HINT_IME_SHOW_UI, "1");

    // Create window with graphics context
    _ = ig.SDL_GL_SetAttribute(ig.SDL_GL_DOUBLEBUFFER, 1);
    _ = ig.SDL_GL_SetAttribute(ig.SDL_GL_DEPTH_SIZE, 24);
    _ = ig.SDL_GL_SetAttribute(ig.SDL_GL_STENCIL_SIZE, 8);
    const window_flags = (ig.SDL_WINDOW_OPENGL | ig.SDL_WINDOW_RESIZABLE | ig.SDL_WINDOW_HIDDEN);
    const window = ig.SDL_CreateWindow("Dear ImGui SDL3+OpenGL3 example", MainWinWidth, MainWinHeight, window_flags);
    if (window == null) {
        try stdout.print("Error: SDL_CreateWindow(): {s}\n", .{ig.SDL_GetError()});
        return error.SDL_CreatWindow;
    }
    defer ig.SDL_DestroyWindow(window);

    _ = ig.SDL_SetWindowPosition(window, ig.SDL_WINDOWPOS_CENTERED, ig.SDL_WINDOWPOS_CENTERED);
    const gl_context = ig.SDL_GL_CreateContext(window);
    defer _ = ig.SDL_GL_DestroyContext(gl_context);

    _ = ig.SDL_GL_MakeCurrent(window, gl_context);
    _ = ig.SDL_GL_SetSwapInterval(1); // Enable vsync
    _ = ig.SDL_ShowWindow(window);

    // Setup Dear ImGui context
    if (ig.ImGui_CreateContext(null) == null) {
        return error.ImGuiCreateContextFailure;
    }
    defer ig.ImGui_DestroyContext(null);

    const pio = ig.ImGui_GetIO();
    pio.*.ConfigFlags |= ig.ImGuiConfigFlags_NavEnableKeyboard; // Enable Keyboard Controls
    pio.*.ConfigFlags |= ig.ImGuiConfigFlags_NavEnableGamepad; // Enable Gamepad Controls
    // Setup doncking feature --- can't compile well at this moment.
    if (IMGUI_HAS_DOCK) {
        pio.*.ConfigFlags |= ig.ImGuiConfigFlags_DockingEnable; // Enable Docking
        pio.*.ConfigFlags |= ig.ImGuiConfigFlags_ViewportsEnable; // Enable Multi-Viewport / Platform Windows
    }

    // Setup Dear ImGui style
    ig.ImGui_StyleColorsDark(null);
    // ig.ImGui_StyleColorsLight(null);
    // ig.ImGui_StyleColorsClassic(null);

    // Setup Platform/Renderer backends
    _ = ig.cImGui_ImplSDL3_InitForOpenGL(window, gl_context);
    defer ig.cImGui_ImplSDL3_Shutdown();
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

    c.setupFonts();

    var done = false;
    while (!done) {
        var event: ig.SDL_Event = undefined;
        while (ig.SDL_PollEvent(&event)) {
            _ = ig.cImGui_ImplSDL3_ProcessEvent(&event);
            if (event.type == ig.SDL_EVENT_QUIT)
                done = true;
            if ((event.type == ig.SDL_EVENT_WINDOW_CLOSE_REQUESTED) and (event.window.windowID == ig.SDL_GetWindowID(window)))
                done = true;
        }

        // Iconify sleep
        if (0 != (ig.SDL_GetWindowFlags(window) & ig.SDL_WINDOW_MINIMIZED)) {
            ig.SDL_Delay(10);
            continue;
        }

        // Start the Dear ImGui frame
        ig.cImGui_ImplOpenGL3_NewFrame();
        ig.cImGui_ImplSDL3_NewFrame();
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
            ig.ImGui_Text(c.ICON_FA_COMMENT ++ " SDL3 v");
            ig.ImGui_SameLine();
            ig.ImGui_Text("[%d],[%s]", ig.SDL_GetVersion(), ig.SDL_GetRevision());
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

            if (ig.ImGui_Button("Button")) counter += 1;
            ig.ImGui_SameLine();
            ig.ImGui_Text("Counter = %d", counter);
            ig.ImGui_Text("Application average %.3f ms/frame (%.1f FPS)", 1000.0 / pio.*.Framerate, pio.*.Framerate);
            // Show icon fonts
            ig.ImGui_SeparatorText(c.ICON_FA_WRENCH ++ " Icon font test ");
            ig.ImGui_Text(c.ICON_FA_TRASH_CAN ++ " Trash");

            ig.ImGui_Spacing();
            ig.ImGui_Text(c.ICON_FA_MAGNIFYING_GLASS_PLUS ++ " " ++ c.ICON_FA_POWER_OFF ++ " " ++ c.ICON_FA_MICROPHONE ++ " " ++ c.ICON_FA_MICROCHIP ++ " " ++ c.ICON_FA_VOLUME_HIGH ++ " " ++ c.ICON_FA_SCISSORS ++ " " ++ c.ICON_FA_SCREWDRIVER_WRENCH ++ " " ++ c.ICON_FA_BLOG);
        } // end main window

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
        ig.glViewport(0, 0, @intFromFloat(pio.*.DisplaySize.x), @intFromFloat(pio.*.DisplaySize.y));
        ig.glClearColor(clearColor[0], clearColor[1], clearColor[2], clearColor[3]);
        ig.glClear(ig.GL_COLOR_BUFFER_BIT);
        ig.cImGui_ImplOpenGL3_RenderDrawData(ig.ImGui_GetDrawData());
        _ = ig.SDL_GL_SwapWindow(window);

        if (showWindowDelay >= 0) {
            showWindowDelay -= 1;
        }
        if (showWindowDelay == 0) { // Visible main window here at start up
            _ = ig.SDL_ShowWindow(window);
        }
    } // while end
} // main end
