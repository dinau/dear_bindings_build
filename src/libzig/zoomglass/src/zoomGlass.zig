const ig = @import("dcimgui");
const ifa = @import("fonticon");
const img_ld = @import("loadimage");

//--------------
//--- zoomGlass
//--------------
pub fn zoomGlass(pTextureID: *u32, itemWidth: i32, itemPosTop: ig.ImVec2, itemPosEnd: ig.ImVec2, capture: bool) void {
    //# itemPosTop and itemPosEnd are absolute position in main window.
    if (ig.ImGui_BeginItemTooltip()) {
        defer ig.ImGui_EndTooltip();
        const itemHeight: i32 = @intFromFloat(itemPosEnd.y - itemPosTop.y);
        const my_tex_w: f32 = @floatFromInt(itemWidth);
        const my_tex_h: f32 = @floatFromInt(itemHeight);
        const wkSize = ig.ImGui_GetMainViewport().*.WorkSize;
        if (capture) {
            img_ld.loadTextureFromBuffer(pTextureID //# TextureID
                , @intFromFloat(itemPosTop.x) //# x start pos
                , @intFromFloat(wkSize.y - itemPosEnd.y) //# y start pos
                , itemWidth, itemHeight); //# Image width and height must be 2^n.
            }
        //#igText("lbp: (%.2f, %.2f)", pio.MousePos.x, pio.MousePos.y)
        const pio = ig.ImGui_GetIO();
        const region_sz = 32.0;
        var region_x = pio.*.MousePos.x - itemPosTop.x - region_sz * 0.5;
        var region_y = pio.*.MousePos.y - itemPosTop.y - region_sz * 0.5;
        const zoom = 4.0;
        if (region_x < 0.0) {
            region_x = 0.0;
        } else if (region_x > (my_tex_w - region_sz)) {
            region_x = my_tex_w - region_sz;
        }
        if (region_y < 0.0) {
            region_y = 0.0;
        } else if (region_y > my_tex_h - region_sz) {
            region_y = my_tex_h - region_sz;
        }
        const uv0 = ig.ImVec2{ .x = region_x / my_tex_w, .y = region_y / my_tex_h };
        const uv1 = ig.ImVec2{ .x = (region_x + region_sz) / my_tex_w, .y = (region_y + region_sz) / my_tex_h };
        ig.ImGui_Text(ifa.ICON_FA_MAGNIFYING_GLASS ++ "  4 x");
        ig.ImGui_ImageEx(ig.ImTextureRef{ ._TexData = null, ._TexID = pTextureID.*}, .{ .x = region_sz * zoom, .y = region_sz * zoom }, uv0, uv1);
    }
}
