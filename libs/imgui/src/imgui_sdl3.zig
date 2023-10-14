const imgui = @import("dear_imgui.zig");
const sdl = @import("sdl");
const imgui_enabled = @import("imgui.zig").enabled;

// all references to SDL_Window, SDL_Event and SDL_Renderer were changed to anyopaque

// imgui_impl_sdl3
pub extern fn ImGui_ImplSDL3_InitForSDLRenderer(window: ?*anyopaque, renderer: ?*anyopaque) bool;
pub extern fn ImGui_ImplSDL3_Shutdown() void;
pub extern fn ImGui_ImplSDL3_NewFrame() void;
extern fn ImGui_ImplSDL3_ProcessEvent(event: ?*anyopaque) bool;

extern fn ImGui_ImplSDLRenderer3_Init(renderer: ?*anyopaque) bool;
extern fn ImGui_ImplSDLRenderer3_Shutdown() void;
extern fn ImGui_ImplSDLRenderer3_NewFrame() void;
extern fn ImGui_ImplSDLRenderer3_RenderDrawData(draw_data: *imgui.ImDrawData) void;

// Called by Init/NewFrame/Shutdown
extern fn ImGui_ImplSDLRenderer3_CreateFontsTexture() bool;
extern fn ImGui_ImplSDLRenderer3_DestroyFontsTexture() void;
extern fn ImGui_ImplSDLRenderer3_CreateDeviceObjects() bool;
extern fn ImGui_ImplSDLRenderer3_DestroyDeviceObjects() void;

// ImGui lifecycle helpers, wrapping ImGui, SDL3 Impl and SDL3 Renderer Impl methods
pub fn init(window: ?*anyopaque, renderer: ?*anyopaque) void {
    if (!imgui_enabled) return;

    _ = imgui.igCreateContext(null);
    var io = imgui.igGetIO().*;
    io.ConfigFlags |= imgui.ImGuiConfigFlags_NavEnableKeyboard;
    io.ConfigFlags |= imgui.ImGuiConfigFlags_NavEnableGamepad;

    _ = ImGui_ImplSDL3_InitForSDLRenderer(window, renderer);
    if (renderer != null)
        _ = ImGui_ImplSDLRenderer3_Init(renderer);
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

    ImGui_ImplSDLRenderer3_NewFrame();
    ImGui_ImplSDL3_NewFrame();
    imgui.igNewFrame();
}

pub fn render() void {
    if (!imgui_enabled) return;

    imgui.igRender();
    ImGui_ImplSDLRenderer3_RenderDrawData(imgui.igGetDrawData());
}

pub fn shutdown() void {
    if (!imgui_enabled) return;

    ImGui_ImplSDLRenderer3_Shutdown();
    ImGui_ImplSDL3_Shutdown();
    imgui.igDestroyContext(null);
}
