const std = @import("std");
const sdl = @import("sdl");
const metal = @import("metal");
const sokol = @import("sokol");
const aya = @import("../aya.zig");

const App = aya.App;

pub const SokolPlugin = struct {
    pub fn build(_: SokolPlugin, app: *App) void {
        const window = app.world.resources.get(aya.Window).?;
        metal.mu_create_metal_layer(window.sdl_window);

        sokol.gfx.setup(.{
            .context = .{
                .metal = .{
                    .device = metal.mu_get_metal_device(window.sdl_window),
                    .renderpass_descriptor_cb = metal.mu_get_render_pass_descriptor,
                    .drawable_cb = metal.mu_get_drawable,
                },
            },
        });

        _ = app.addSystems(aya.Last, RenderClear);
    }
};

var pass_action: sokol.gfx.PassAction = .{};

const RenderClear = struct {
    pub fn run(window_res: aya.Res(aya.Window)) void {
        const window = window_res.getAssertExists();

        pass_action.colors[0] = .{
            .load_action = .CLEAR,
            .clear_value = .{ .r = 1, .g = 1, .b = 0, .a = 1 },
        };

        const size = window.sizeInPixels();
        sokol.gfx.beginDefaultPass(pass_action, size.w, size.h);
        sokol.gfx.endPass();
        sokol.gfx.commit();
    }
};
