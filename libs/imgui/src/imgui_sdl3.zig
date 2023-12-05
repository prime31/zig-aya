const imgui = @import("dear_imgui.zig");
const sdl = @import("sdl");
const imgui_enabled = @import("imgui.zig").enabled;

// all references to SDL_Window, SDL_Event and SDL_Renderer were changed to anyopaque

// ImGui lifecycle helpers, wrapping ImGui and SDL3 Impl
pub fn init(
    window: *const anyopaque, // SDL_Window
    wgpu_device: *const anyopaque, // wgpu.Device
    wgpu_swap_chain_format: u32, // wgpu.TextureFormat
    depth_format: u32, // wgpu.TextureFormat
) void {
    if (!imgui_enabled) return;

    _ = imgui.igCreateContext(null);
    _ = imgui.ImFontAtlas_AddFontFromFileTTF(imgui.igGetIO()[0].Fonts, "examples/assets/Roboto-Medium.ttf", 14, null, null);

    var io = imgui.igGetIO().*;
    io.ConfigFlags |= imgui.ImGuiConfigFlags_NavEnableKeyboard;
    io.ConfigFlags |= imgui.ImGuiConfigFlags_NavEnableGamepad;

    if (!ImGui_ImplSDL3_InitForOther(window)) unreachable;
    if (!ImGui_ImplWGPU_Init(wgpu_device, 1, wgpu_swap_chain_format, depth_format)) unreachable;
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

    ImGui_ImplWGPU_NewFrame();
    ImGui_ImplSDL3_NewFrame();

    imgui.igNewFrame();
}

pub fn draw(gctx: anytype, encoder: anytype, texture_view: anytype) void {
    if (!imgui_enabled) return;

    const pass = gctx.beginRenderPassSimple(encoder, .load, texture_view, null, null, null);
    render(pass);
    pass.end();
    pass.release();
}

pub fn render(wgpu_render_pass: *const anyopaque) void {
    if (!imgui_enabled) return;

    imgui.igRender();
    ImGui_ImplWGPU_RenderDrawData(imgui.igGetDrawData(), wgpu_render_pass);
}

pub fn shutdown() void {
    if (!imgui_enabled) return;

    ImGui_ImplWGPU_Shutdown();
    ImGui_ImplSDL3_Shutdown();
    imgui.igDestroyContext(null);
}

// imgui_impl_sdl3
extern fn ImGui_ImplSDL3_InitForSDLRenderer(window: ?*anyopaque, renderer: ?*anyopaque) bool;
extern fn ImGui_ImplSDL3_InitForOther(window: ?*const anyopaque) bool;
extern fn ImGui_ImplSDL3_Shutdown() void;
extern fn ImGui_ImplSDL3_NewFrame() void;
extern fn ImGui_ImplSDL3_ProcessEvent(event: ?*anyopaque) bool;

// imgui_impl_wgpu
extern fn ImGui_ImplWGPU_Init(device: *const anyopaque, num_frames_in_flight: u32, rt_format: u32, depth_format: u32) bool;
extern fn ImGui_ImplWGPU_NewFrame() void;
extern fn ImGui_ImplWGPU_RenderDrawData(draw_data: *const anyopaque, pass_encoder: *const anyopaque) void;
extern fn ImGui_ImplWGPU_Shutdown() void;
