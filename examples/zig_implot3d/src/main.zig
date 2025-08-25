const std = @import("std");
const ig = @import("dcimgui");
const ip = @import("implot");
const ipz = @import("zimplot.zig");
const ip3 = @import("implot3d");
const ifa = @import("fonticon");
const app = @import("appimgui");
const stf = @import("setupfont");

pub const c = @cImport({
    @cInclude("stdlib.h");
});

const IMGUI_HAS_DOCK = false; // Docking feature

const MainWinWidth: i32 = 1024;
const MainWinHeight: i32 = 900;

//-----------
// gui_main()
//-----------
pub fn gui_main(window: *app.Window) !void {
    stf.setupFonts(); // Setup CJK fonts and Icon fonts

    // setup ImPlot
    const imPlotContext = ip.ImPlot_CreateContext();
    defer ip.ImPlot_DestroyContext(imPlotContext);
    //--- 3D
    const imPlot3DContext = ip3.ImPlot3D_CreateContext();
    defer ip3.ImPlot3D_DestroyContext(imPlot3DContext);

    //-------------
    // Global vars
    //-------------

    //------------------------
    // Select Dear ImGui style
    //------------------------
    ig.ImGui_StyleColorsClassic(null);
    //ig.ImGui_StyleColorsDark (null);
    //ig.ImGui_StyleColorsLight (null);

    const pio = ig.ImGui_GetIO();

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
        ip.ImPlot_ShowDemoWindow(null);
        ip3.ImPlot3D_ShowDemoWindow(null);

        //----------------------------
        // Show ImPlot3D demo window
        //----------------------------
        {
            _ = ig.ImGui_Begin(ifa.ICON_FA_THUMBS_UP ++ " Dear ImGui: Dear_Bindings", null, 0);
            defer ig.ImGui_End();
            // Static vars
            const N = 20;
            const st = struct {
                var xs: [N * N]f32 = undefined;
                var ys: [N * N]f32 = undefined;
                var zs: [N * N]f32 = undefined;
                var t: f32 = 0.0;
                //
                var selected_fill: c_int = 1; // Colormap by default
                var sel_colormap: c_int = 5; // Jet by default

                var solid_color = ig.ImVec4{ .x = 0.8, .y = 0.8, .z = 0.2, .w = 0.6 };
                // Generate colormaps
                var colormaps = [_][*c]const u8{ "Viridis", "Plasma", "Hot", "Cool", "Pink", "Jet", "Twilight", "RdBu", "BrBG", "PiYG", "Spectral", "Greys" };
                //
                var custom_range = false;
                var range_min: f32 = -1.0;
                var range_max: f32 = 1.0;
            };

            ig.ImGui_Text("Frame rate  %.3f ms/frame (%.1f FPS)", 1000.0 / pio.*.Framerate, pio.*.Framerate);
            st.t += ig.ImGui_GetIO().*.DeltaTime;
            // Define the range for X and Y
            const min_val: f32 = -1.0;
            const max_val: f32 = 1.0;
            const step = (max_val - min_val) / (N - 1);
            // Populate the xs, ys, and zs arrays

            //var i: usize = 0;
            //while (i < N) : (i += 1) {
            //    var j: usize = 0;
            //    while (j < N) : (j += 1) {
            //        const idx = i * N + j;
            //        st.xs[idx] = min_val + @as(f32, @floatFromInt(j)) * step; // X values are constant along rows
            //        st.ys[idx] = min_val + @as(f32, @floatFromInt(i)) * step; // Y values are constant along columns
            //        st.zs[idx] = std.math.sin(2 * st.t + std.math.sqrt((st.xs[idx] * st.xs[idx] + st.ys[idx] * st.ys[idx]))); // z = sin(2t + sqrt(x^2 + y^2))
            //    }
            //}

            for (0..N) |i| {
                for (0..N) |j| {
                    const idx = i * N + j;
                    st.xs[idx] = min_val + @as(f32, @floatFromInt(j)) * step; // X values are constant along rows
                    st.ys[idx] = min_val + @as(f32, @floatFromInt(i)) * step; // Y values are constant along columns
                    st.zs[idx] = std.math.sin(2 * st.t + std.math.sqrt((st.xs[idx] * st.xs[idx] + st.ys[idx] * st.ys[idx]))); // z = sin(2t + sqrt(x^2 + y^2))
                    if (!(j < N)) break;
                }
                if (!(i < N)) break;
            }

            // Choose fill color
            ig.ImGui_Text("Fill color");
            ig.ImGui_Indent();
            // Choose solid color
            _ = ig.ImGui_RadioButtonIntPtr("Solid", &st.selected_fill, 0);
            if (st.selected_fill == 0) {
                ig.ImGui_SameLine();
                _ = ig.ImGui_ColorEdit4("##SurfaceSolidColor", @ptrCast(&st.solid_color), 0);
            }
            // Choose colormap
            _ = ig.ImGui_RadioButtonIntPtr("Colormap", &st.selected_fill, 1);
            if (st.selected_fill == 1) {
                ig.ImGui_SameLine();
                _ = ig.ImGui_ComboChar("##SurfaceColormap", &st.sel_colormap, &st.colormaps, st.colormaps.len);
            }
            ig.ImGui_Unindent();

            // Choose range
            _ = ig.ImGui_Checkbox("Custom range", &st.custom_range);
            ig.ImGui_Indent();
            if (!st.custom_range) {
                ig.ImGui_BeginDisabled(true);
            }
            _ = ig.ImGui_SliderFloat("Range min", &st.range_min, -1.0, st.range_max - 0.01);
            _ = ig.ImGui_SliderFloat("Range max", &st.range_max, st.range_min + 0.01, 1.0);
            if (!st.custom_range) {
                ig.ImGui_EndDisabled();
            }
            ig.ImGui_Unindent();

            // Begin the plot
            if (st.selected_fill == 1) {
                ip3.ImPlot3D_PushColormap_Str(st.colormaps[@intCast(st.sel_colormap)]);
            }
            if (ip3.ImPlot3D_BeginPlot("Surface Plots", .{ .x = -1, .y = 400 }, ip3.ImPlot3DFlags_NoClip)) {
                // Set styles
                ip3.ImPlot3D_SetupAxesLimits(-1, 1, -1, 1, -1.5, 1.5, ip3.ImPlot3DCond_Once);
                ip3.ImPlot3D_PushStyleVar_Float(ip3.ImPlot3DStyleVar_FillAlpha, 0.8);
                const IMPLOT3D_AUTO = -1; // Deduce variable automatically
                if (st.selected_fill == 0) {
                    ip3.ImPlot3D_SetNextFillStyle(.{ .x = st.solid_color.x, .y = st.solid_color.y, .z = st.solid_color.z, .w = st.solid_color.w }, IMPLOT3D_AUTO);
                }
                var vec4: ig.ImVec4 = undefined;
                ip3.ImPlot3D_GetColormapColor(@ptrCast(&vec4), 1, IMPLOT3D_AUTO);
                ip3.ImPlot3D_SetNextLineStyle(.{ .x = vec4.x, .y = vec4.y, .z = vec4.z, .w = vec4.w }, IMPLOT3D_AUTO);

                // Plot the surface
                if (st.custom_range) {
                    ip3.ImPlot3D_PlotSurface_FloatPtr("Wave Surface", &st.xs, &st.ys, &st.zs, N, N, st.range_min, st.range_max, 0, 0, @sizeOf(f32));
                } else {
                    ip3.ImPlot3D_PlotSurface_FloatPtr("Wave Surface", &st.xs, &st.ys, &st.zs, N, N, 0, 0, 0, 0, @sizeOf(f32));
                }
                // End the plot
                ip3.ImPlot3D_PopStyleVar(1);
                ip3.ImPlot3D_EndPlot();
            }
            if (st.selected_fill == 1) {
                ip3.ImPlot3D_PopColormap(1);
            }
        } // end ImPlot3d demo window

        //--------
        // render
        //--------
        window.render();
    } // end while
} // end main window

//--------
// main()
//--------
pub fn main() !void {
    var window = try app.Window.createImGui(MainWinWidth, MainWinHeight, "ImGui window in Zig lang.");
    defer window.destroyImGui();

    //_ = app.setTheme(app.Theme.light); // Theme: dark, classic, light, microsoft

    //---------------
    // GUI main proc
    //---------------
    try gui_main(&window);
}
