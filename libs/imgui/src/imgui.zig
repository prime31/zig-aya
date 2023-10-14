pub usingnamespace @import("dear_imgui.zig");
pub const sdl = @import("imgui_sdl3.zig");
pub const enabled = @import("options").enable_imgui;

pub const sokol = struct {
    const sg = @import("sokol").gfx;
    const sgig = @import("sokol_imgui.zig");

    pub fn init(window: ?*anyopaque) void {
        if (!enabled) return;

        sgig.simgui_setup(&.{
            .ini_filename = "imgui.ini",
            .logger = .{ .func = @import("sokol").log.func },
        });
        _ = sdl.ImGui_ImplSDL3_InitForSDLRenderer(window, null);
    }

    pub fn newFrame(width: c_int, height: c_int) void {
        if (!enabled) return;

        sdl.ImGui_ImplSDL3_NewFrame();
        sgig.simgui_new_frame(&.{
            .width = width,
            .height = height,
            .delta_time = 0.016, // TODO
            .dpi_scale = 1, // TODO
        });
    }

    pub fn render() void {
        if (!enabled) return;
        sgig.simgui_render();
    }

    pub fn shutdown() void {
        if (!enabled) return;
        sgig.simgui_shutdown();
    }
};
