const std = @import("std");
const sdl = @import("sdl");
const imgui = @import("dear_imgui.zig");
const icons = @import("imgui.zig").icons;
const imgui_enabled = @import("imgui.zig").enabled;

pub const Config = struct {
    icon_font: bool = true,
    viewports: bool = true, // whether imgui viewports should be enabled
    docking: bool = true, // whether imgui docking should be enabled
};

// all references to SDL_Window, SDL_Event and SDL_Renderer were changed to anyopaque

// ImGui lifecycle helpers, wrapping ImGui and SDL3 Impl
pub fn init(window: *const anyopaque, config: Config) void {
    if (!imgui_enabled) return;

    _ = imgui.igCreateContext(null);

    var io = imgui.igGetIO();
    io.ConfigFlags |= imgui.ImGuiConfigFlags_NavEnableKeyboard;
    io.ConfigFlags |= imgui.ImGuiConfigFlags_NavEnableGamepad;
    if (config.docking) io.ConfigFlags |= imgui.ImGuiConfigFlags_DockingEnable;
    if (config.viewports) io.ConfigFlags |= imgui.ImGuiConfigFlags_ViewportsEnable;

    _ = imgui.ImFontAtlas_AddFontDefault(io.Fonts, null);

    // optionally FontAwesome
    if (config.icon_font) {
        var icons_config = imgui.ImFontConfig_ImFontConfig();
        icons_config[0].MergeMode = true;
        icons_config[0].PixelSnapH = true;
        icons_config[0].FontDataOwnedByAtlas = false;
        icons_config[0].GlyphOffset = .{ .x = 0, .y = 2 };

        const font_awesome_range: [3]imgui.ImWchar = [_]imgui.ImWchar{ icons.icon_range_min, icons.icon_range_max, 0 };
        var data = @embedFile("assets/" ++ icons.font_icon_filename_fas);
        _ = imgui.ImFontAtlas_AddFontFromMemoryTTF(io.Fonts, @constCast(data.ptr), data.len, 14, icons_config, &font_awesome_range);
        _ = imgui.ImFontAtlas_Build(io.Fonts);
    }

    if (!ImGui_ImplOpenGL3_Init(null)) unreachable;
    if (!ImGui_ImplSDL3_InitForOpenGL(window, sdl.SDL_GL_GetCurrentContext())) unreachable;
}

/// returns true if the event is handled by imgui and should be ignored
pub fn handleEvent(event: *sdl.SDL_Event) bool {
    if (!imgui_enabled) return false;

    if (ImGui_ImplSDL3_ProcessEvent(event)) {
        return switch (event.type) {
            sdl.SDL_EVENT_MOUSE_WHEEL, sdl.SDL_EVENT_MOUSE_BUTTON_DOWN => return imgui.igGetIO().*.WantCaptureMouse,
            sdl.SDL_EVENT_KEY_DOWN, sdl.SDL_EVENT_KEY_UP, sdl.SDL_EVENT_TEXT_INPUT => return imgui.igGetIO().*.WantCaptureKeyboard,
            else => return false,
        };
    }
    return false;
}

pub fn newFrame() void {
    if (!imgui_enabled) return;

    ImGui_ImplOpenGL3_NewFrame();
    ImGui_ImplSDL3_NewFrame();
    imgui.igNewFrame();
}

pub fn render(window: *sdl.SDL_Window, gl_ctx: sdl.SDL_GLContext) void {
    if (!imgui_enabled) return;

    imgui.igRender();
    ImGui_ImplOpenGL3_RenderDrawData(imgui.igGetDrawData());

    var io = imgui.igGetIO();
    if ((io.ConfigFlags & imgui.ImGuiConfigFlags_ViewportsEnable) != 0) {
        imgui.igUpdatePlatformWindows();
        imgui.igRenderPlatformWindowsDefault(null, null);
        _ = sdl.SDL_GL_MakeCurrent(window, gl_ctx);
    }
}

pub fn shutdown() void {
    if (!imgui_enabled) return;

    ImGui_ImplOpenGL3_Shutdown();
    ImGui_ImplSDL3_Shutdown();
    imgui.igDestroyContext(null);
}

// imgui_impl_sdl3
extern fn ImGui_ImplSDL3_InitForOpenGL(window: ?*const anyopaque, sdl_gl_context: ?*anyopaque) bool;
extern fn ImGui_ImplSDL3_Shutdown() void;
extern fn ImGui_ImplSDL3_NewFrame() void;
extern fn ImGui_ImplSDL3_ProcessEvent(event: ?*anyopaque) bool;

// imgui_impl_gl3
pub extern fn ImGui_ImplOpenGL3_Init(glsl_version: [*c]const u8) bool;
pub extern fn ImGui_ImplOpenGL3_NewFrame() void;
pub extern fn ImGui_ImplOpenGL3_RenderDrawData(draw_data: ?*anyopaque) void;
pub extern fn ImGui_ImplOpenGL3_Shutdown() void;
