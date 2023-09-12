const imgui = @import("dear_imgui.zig");

// all references to SDL_Window, SDL_Event and SDL_Renderer were changed to anyopaque

// imgui_impl_sdl3
pub extern fn ImGui_ImplSDL3_InitForSDLRenderer(window: ?*anyopaque, renderer: ?*anyopaque) bool;
pub extern fn ImGui_ImplSDL3_Shutdown() void;
pub extern fn ImGui_ImplSDL3_NewFrame() void;
pub extern fn ImGui_ImplSDL3_ProcessEvent(event: ?*anyopaque) bool;

pub extern fn ImGui_ImplSDLRenderer3_Init(renderer: ?*anyopaque) bool;
pub extern fn ImGui_ImplSDLRenderer3_Shutdown() void;
pub extern fn ImGui_ImplSDLRenderer3_NewFrame() void;
pub extern fn ImGui_ImplSDLRenderer3_RenderDrawData(draw_data: *imgui.ImDrawData) void;

// Called by Init/NewFrame/Shutdown
pub extern fn ImGui_ImplSDLRenderer3_CreateFontsTexture() bool;
pub extern fn ImGui_ImplSDLRenderer3_DestroyFontsTexture() void;
pub extern fn ImGui_ImplSDLRenderer3_CreateDeviceObjects() bool;
pub extern fn ImGui_ImplSDLRenderer3_DestroyDeviceObjects() void;
