const ig = @import("dcimgui");
const ip = @import("implot");
const ifa = @import("fonticon");
const demo = @import ("demoAll.zig");
const app = @import("appimgui");
const stf = @import("setupfont");

const IMGUI_HAS_DOCK = false;    // Docking feature

const MainWinWidth :i32 = 1200;
const MainWinHeight:i32 = 800;

//-----------
// gui_main()
//-----------
pub fn gui_main(window: *app.Window) !void {
    stf.setupFonts(); // Setup CJK fonts and Icon fonts

  const imPlotContext = ip.ImPlot_CreateContext();
  defer  ip.ImPlot_DestroyContext(imPlotContext);

  //-------------
  // Global vars
  //-------------
  var showDemoWindow = true;
  var showImPlotDemoWindow = true;

  //------------------------
  // Select Dear ImGui style
  //------------------------
  ig.ImGui_StyleColorsClassic(null);
  //ig.ImGui_StyleColorsDark (null);
  //ig.ImGui_StyleColorsLight (null);

  //---------------
  // main loop GUI
  //---------------
    while (!window.shouldClose ()) {
        window.pollEvents ();

        // Iconify sleep
        if( window.isIconified()){
            continue;
        }

        // Start the Dear ImGui frame
        window.frame();

        //------------------
        // Show demo window
        //------------------
        ig.ImGui_ShowDemoWindow (&showDemoWindow);
        if (showImPlotDemoWindow) {
            ip.ImPlot_ShowDemoWindow (&showImPlotDemoWindow);
        }
        window.showInfoWindow();

        try imPlotDemoWindow();

        //--------
        // render
        //--------
        window.render();
    } // while end
} // main end


//------------------
// imPlotDemoWindow
//-------------------
fn imPlotDemoWindow() !void {
  {
    _ = ig.ImGui_Begin(ifa.ICON_FA_SIGNAL ++ " ImPlot demo: All demos have been written in Zig lang.", null, 0);
    defer ig.ImGui_End();
    try demo.imPlotDemoTabs();
  }
}

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
