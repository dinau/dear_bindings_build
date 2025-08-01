const ig = @import("dcimgui");
const stf = @import("setupfont");
const ifa = @import("fonticon");
const app = @import("appimgui");

const knobs = @import("imknobs");

//-----------
// gui_main()
//-----------
pub fn gui_main(window: *app.Window) void {
    stf.setupFonts(); // Setup CJK fonts and Icon fonts

    //---------------
    // main loop GUI
    //---------------
    while (!window.shouldClose()) {
        window.pollEvents();

        // Iconify sleep
        if (window.isIconified()) {
            continue;
        }

        // Start the Dear ImGui frame
        window.frame();

        //------------------
        // Show demo window
        //------------------
        ig.ImGui_ShowDemoWindow(null);

        //-----------------------
        // Show ImKnobs window
        //-----------------------
        {
            _ = ig.ImGui_Begin("ImKnobs: Dear Bindings in Zig  2025/07 " ++ ifa.ICON_FA_DOG, null, 0);
            defer ig.ImGui_End();
            const st = struct {
                var val1: f32 = 0;
                var val2: f32 = 0;
                var val3: f32 = 0;
                var val4: f32 = 0;
                var val5: i32 = 1;
                var val6: f32 = 1;
            };
            if (knobs.IgKnobFloat("Gain", &st.val1, -6.0, 6.0, 0.1, "%.1fdB", knobs.IgKnobVariant_Tick, 0, 0, 10, -1, -1)) {
                window.ini.window.colBGx = (st.val1 + 6) / 12;
            }
            ig.ImGui_SameLine();
            if (knobs.IgKnobFloat("Mix", &st.val2, -1.0, 1.0, 0.1, "%.1f", knobs.IgKnobVariant_Stepped, 0, 0, 10, -1, -1)) {
                window.ini.window.colBGy = (st.val2 + 1) / 2;
            }
            // Double click to reset
            if (ig.ImGui_IsItemActive() and ig.ImGui_IsMouseDoubleClicked(0)) {
                window.ini.window.colBGy = 0;
                st.val2 = 0;
            }
            ig.ImGui_SameLine();

            // Custom colors
            ig.ImGui_PushStyleColorImVec4(ig.ImGuiCol_ButtonActive, .{ .x = 255.0, .y = 0, .z = 0, .w = 0.7 });
            ig.ImGui_PushStyleColorImVec4(ig.ImGuiCol_ButtonHovered, .{ .x = 255.0, .y = 0, .z = 0, .w = 1 });
            ig.ImGui_PushStyleColorImVec4(ig.ImGuiCol_Button, .{ .x = 0, .y = 255.0, .z = 0, .w = 1 });
            // Push/PopStyleColor() for each colors used (namely ImGuiCol_ButtonActive and ImGuiCol_ButtonHovered for primary and ImGuiCol_Framebg for Track)
            if (knobs.IgKnobFloat("Pitch", &st.val3, -6.0, 6.0, 0.1, "%.1f", knobs.IgKnobVariant_WiperOnly, 0, 0, 10, -1, -1)) {
                window.ini.window.colBGz = (st.val3 + 6.0) / 12.0;
            }
            ig.ImGui_PopStyleColorEx(3);
            ig.ImGui_SameLine();

            // Custom min/max angle
            if (knobs.IgKnobFloat("Dry", &st.val4, -6.0, 6.0, 0.1, "%.1f", knobs.IgKnobVariant_Stepped, 0, 0, 10, 1.570796, 3.141592)) {
                window.ini.window.colBGx = (st.val4 + 6.0) / 12.0;
            }
            ig.ImGui_SameLine();

            // Int value
            if (knobs.IgKnobInt("Wet", &st.val5, 1, 10, 0.1, "%i", knobs.IgKnobVariant_Stepped, 0, 0, 10, -1, -1)) {
                window.ini.window.colBGy = @as(f32, @floatFromInt(st.val5)) / 10.0;
            }
            ig.ImGui_SameLine();

            // Vertical drag only
            if (knobs.IgKnobFloat("Vertical", &st.val6, 0.0, 10.0, 0.1, "%.1f", knobs.IgKnobVariant_Space, 0, knobs.IgKnobFlags_DragVertical, 10, -1, -1)) {
                window.ini.window.colBGz = st.val6 / 10.0;
            }
            ig.ImGui_SameLine();
        }

        //------------------
        // Show info window
        //------------------
        window.showInfoWindow(); // See:  ../../src/libzig/appimgui/appImGui.zig

        //--------
        // render
        //--------
        window.render();
    } // end while loop
}

//--------
// main()
//--------
const MainWinWidth: i32 = 1024;
const MainWinHeight: i32 = 900;

pub fn main() !void {
    var window = try app.Window.createImGui(MainWinWidth, MainWinHeight, "ImGui window in Zig lang.");
    defer window.destroyImGui();

    //_ = app.setTheme(app.Theme.light); // Theme: dark, classic, light, microsoft

    //---------------
    // GUI main proc
    //---------------
    gui_main(&window);
}
