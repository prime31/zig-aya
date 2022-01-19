const aya = @import("aya");
const imgui = @import("imgui");

const Color = aya.math.Color;

pub var ui_tint: imgui.ImVec4 = rgbaToVec4(135, 45, 176, 255);

pub var brush_required: imgui.ImU32 = 0;
pub var brush_negated: imgui.ImU32 = 0;
pub var brush_selected: imgui.ImU32 = 0;

pub var pattern_center: imgui.ImU32 = 0;
pub var rule_result_selected_outline: imgui.ImU32 = 0;
pub var rule_result_selected_fill: imgui.ImU32 = 0;

pub var scene_toolbar_btn: imgui.ImU32 = aya.math.Color.aya.value;

// TODO: these are duplicated in Tileset
pub var brushes = [_]imgui.ImU32{
    Color.fromRgbBytes(189, 63, 110).value,  Color.fromRgbBytes(242, 165, 59).value,  Color.fromRgbBytes(252, 234, 87).value,
    Color.fromRgbBytes(103, 223, 84).value,  Color.fromRgbBytes(82, 172, 247).value,  Color.fromRgbBytes(128, 118, 152).value,
    Color.fromRgbBytes(237, 127, 166).value, Color.fromRgbBytes(246, 205, 174).value, Color.fromRgbBytes(115, 45, 81).value,
};

pub fn init() void {
    setDefaultImGuiStyle();

    brush_required = rgbToU32(117, 249, 76);
    brush_negated = rgbToU32(235, 50, 35);
    brush_selected = rgbToU32(82, 172, 247);

    pattern_center = rgbToU32(255, 253, 84);
    rule_result_selected_outline = rgbToU32(116, 252, 253);
    rule_result_selected_fill = rgbaToU32(116, 252, 253, 100);
}

fn setDefaultImGuiStyle() void {
    var style = imgui.igGetStyle();
    style.TabRounding = 2;
    style.FrameRounding = 4;
    style.WindowBorderSize = 1;
    style.WindowRounding = 0;
    style.WindowMenuButtonPosition = imgui.ImGuiDir_None;
    style.Colors[imgui.ImGuiCol_WindowBg] = imgui.ogColorConvertU32ToFloat4(rgbaToU32(25, 25, 25, 255));
    style.Colors[imgui.ImGuiCol_TextSelectedBg] = imgui.ogColorConvertU32ToFloat4(rgbaToU32(66, 150, 250, 187));
    style.Colors[imgui.ImGuiCol_PopupBg] = rgbaToVec4(20, 20, 20, 255);

    setTintColor(ui_tint);
}

pub fn setTintColor(color: imgui.ImVec4) void {
    var colors = &imgui.igGetStyle().Colors;
    colors[imgui.ImGuiCol_FrameBg] = hsvShiftColor(color, 0, 0, -0.2, colors[imgui.ImGuiCol_FrameBg].w);
    colors[imgui.ImGuiCol_FrameBgHovered] = hsvShiftColor(color, 0, -0.2, 0, colors[imgui.ImGuiCol_FrameBgHovered].w);
    colors[imgui.ImGuiCol_FrameBgActive] = hsvShiftColor(color, 0, -0.2, 0, colors[imgui.ImGuiCol_FrameBgActive].w);
    colors[imgui.ImGuiCol_Border] = hsvShiftColor(color, 0, 0, -0.2, colors[imgui.ImGuiCol_Border].w);

    const header = hsvShiftColor(color, 0, -0.2, 0, colors[imgui.ImGuiCol_Header].w);
    colors[imgui.ImGuiCol_Header] = header;
    colors[imgui.ImGuiCol_HeaderHovered] = hsvShiftColor(header, 0, 0, 0.1, colors[imgui.ImGuiCol_HeaderHovered].w);
    colors[imgui.ImGuiCol_HeaderActive] = hsvShiftColor(header, 0, 0, -0.1, colors[imgui.ImGuiCol_HeaderActive].w);

    colors[imgui.ImGuiCol_TitleBg] = hsvShiftColor(color, 0, 0.1, 0, colors[imgui.ImGuiCol_TitleBg].w);
    colors[imgui.ImGuiCol_TitleBgActive] = hsvShiftColor(color, 0, 0.1, 0, colors[imgui.ImGuiCol_TitleBgActive].w);

    const tab = hsvShiftColor(color, 0, 0.1, 0, 1.0);
    colors[imgui.ImGuiCol_Tab] = tab;
    colors[imgui.ImGuiCol_TabActive] = hsvShiftColor(tab, 0.05, 0.2, 0.2, colors[imgui.ImGuiCol_TabActive].w);
    colors[imgui.ImGuiCol_TabHovered] = hsvShiftColor(tab, 0.02, 0.1, 0.2, colors[imgui.ImGuiCol_TabHovered].w);
    colors[imgui.ImGuiCol_TabUnfocused] = hsvShiftColor(tab, 0, -0.1, 0, colors[imgui.ImGuiCol_TabUnfocused].w);
    colors[imgui.ImGuiCol_TabUnfocusedActive] = colors[imgui.ImGuiCol_TabActive];

    const button = hsvShiftColor(color, -0.05, 0, 0, 1.0);
    colors[imgui.ImGuiCol_Button] = button;
    colors[imgui.ImGuiCol_ButtonHovered] = hsvShiftColor(button, 0, 0, 0.1, colors[imgui.ImGuiCol_ButtonHovered].w);
    colors[imgui.ImGuiCol_ButtonActive] = hsvShiftColor(button, 0, 0, -0.1, colors[imgui.ImGuiCol_ButtonActive].w);
}

pub fn hsvShiftColor(color: imgui.ImVec4, h_shift: f32, s_shift: f32, v_shift: f32, alpha: f32) imgui.ImVec4 {
    _ = alpha;
    var h: f32 = undefined;
    var s: f32 = undefined;
    var v: f32 = undefined;
    imgui.igColorConvertRGBtoHSV(color.x, color.y, color.z, &h, &s, &v);

    h += h_shift;
    s += s_shift;
    v += v_shift;

    var out_color = color;
    imgui.igColorConvertHSVtoRGB(h, s, v, &out_color.x, &out_color.y, &out_color.z);
    return out_color;
}

pub fn rgbToU32(r: i32, g: i32, b: i32) imgui.ImU32 {
    return aya.math.Color.fromI32(r, g, b, 255).value;
}

pub fn rgbaToU32(r: i32, g: i32, b: i32, a: i32) imgui.ImU32 {
    return aya.math.Color.fromI32(r, g, b, a).value;
}

pub fn rgbToVec4(r: i32, g: i32, b: i32) imgui.ImVec4 {
    return .{ .x = @intToFloat(f32, r) / 255, .y = @intToFloat(f32, g) / 255, .z = @intToFloat(f32, b) / 255, .w = 1 };
}

pub fn rgbaToVec4(r: i32, g: i32, b: i32, a: i32) imgui.ImVec4 {
    return .{ .x = @intToFloat(f32, r) / 255, .y = @intToFloat(f32, g) / 255, .z = @intToFloat(f32, b) / 255, .w = @intToFloat(f32, a) };
}
