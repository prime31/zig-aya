const std = @import("std");
const imgui = @import("imgui");
const imgui_gl = @import("imgui_gl");
const sdl = @import("sdl");
const aya = @import("../../aya.zig");

const Window = @import("../window.zig").Window;

// public methods
pub fn init(window: Window, docking: bool, viewports: bool, icon_font: bool) void {
    _ = imgui.igCreateContext(null);
    var io = imgui.igGetIO();
    io.ConfigFlags |= imgui.ImGuiConfigFlags_NavEnableKeyboard;
    if (docking) io.ConfigFlags |= imgui.ImGuiConfigFlags_DockingEnable;
    if (viewports) io.ConfigFlags |= imgui.ImGuiConfigFlags_ViewportsEnable;
    imgui_gl.initForGl(null, window.sdl_window, window.gl_ctx);

    _ = imgui.ImFontAtlas_AddFontDefault(io.Fonts, null);

    // add FontAwesome optionally
    if (icon_font) {
        var icons_config = imgui.ImFontConfig_ImFontConfig();
        icons_config[0].MergeMode = true;
        icons_config[0].PixelSnapH = true;
        icons_config[0].FontDataOwnedByAtlas = false;
        icons_config[0].GlyphOffset = .{ .x = 0, .y = 2 };

        const font_awesome_range: [3]imgui.ImWchar = [_]imgui.ImWchar{ imgui.icons.icon_range_min, imgui.icons.icon_range_max, 0 };
        var data = @embedFile("assets/" ++ imgui.icons.font_icon_filename_fas);
        _ = imgui.ImFontAtlas_AddFontFromMemoryTTF(io.Fonts, data, data.len, 14, icons_config, &font_awesome_range[0]);
    }

    var style = imgui.igGetStyle();
    style.WindowRounding = 0;
}

pub fn deinit() void {
    imgui_gl.shutdown();
}

pub fn newFrame() void {
    imgui_gl.newFrame(aya.window.sdl_window);
}

pub fn render() void {
    imgui_gl.render();
}

/// returns true if the event is handled by imgui and should be ignored
pub fn handleEvent(event: *sdl.SDL_Event) bool {
    if (imgui_gl.ImGui_ImplSDL2_ProcessEvent(event)) {
        return switch (event.type) {
            sdl.SDL_MOUSEWHEEL, sdl.SDL_MOUSEBUTTONDOWN => return imgui.igGetIO().WantCaptureMouse,
            sdl.SDL_KEYDOWN, sdl.SDL_KEYUP, sdl.SDL_TEXTINPUT => return imgui.igGetIO().WantCaptureKeyboard,
            sdl.SDL_WINDOWEVENT => return true,
            else => return false,
        };
    }
    return false;
}
