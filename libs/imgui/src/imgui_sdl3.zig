const imgui = @import("dear_imgui.zig");
const sdl = @import("sdl");
const imgui_enabled = @import("imgui.zig").enabled;

// all references to SDL_Window, SDL_Event and SDL_Renderer were changed to anyopaque

// ImGui lifecycle helpers, wrapping ImGui and SDL3 Impl
pub fn init(window: *const anyopaque) void {
    if (!imgui_enabled) return;

    _ = imgui.igCreateContext(null);
    var io = imgui.igGetIO();
    _ = imgui.ImFontAtlas_AddFontFromFileTTF(io.Fonts, "examples/assets/Roboto-Medium.ttf", 14, null, null);

    io.ConfigFlags |= imgui.ImGuiConfigFlags_NavEnableKeyboard;
    io.ConfigFlags |= imgui.ImGuiConfigFlags_NavEnableGamepad;
    io.ConfigFlags |= imgui.ImGuiConfigFlags_DockingEnable;
    io.ConfigFlags |= imgui.ImGuiConfigFlags_ViewportsEnable;

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
    }

    _ = sdl.SDL_GL_MakeCurrent(window, gl_ctx);
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
