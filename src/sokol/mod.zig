const std = @import("std");
const sdl = @import("sdl");
const metal = @import("metal");
const sokol = @import("sokol");
const aya = @import("../aya.zig");

const App = aya.App;
const Window = aya.Window;
const Res = aya.Res;

/// Resource. stores the color that is used to clear the screen between frames
pub const ClearColor = struct {
    r: f32 = 0.8,
    g: f32 = 0.2,
    b: f32 = 0.3,
    a: f32 = 1,
};

/// Component. controls a Camera's clear behavior
pub const ClearColorConfig = union {
    /// The clear color is taken from the world's [`ClearColor`] resource.
    default: void,
    /// The given clear color is used, overriding the [`ClearColor`] resource defined in the world
    custom: ClearColor,
    /// No clear color is used: the camera will simply draw on top of anything already in the viewport
    none: void,
};

pub const SokolPlugin = struct {
    pub fn build(_: SokolPlugin, app: *App) void {
        const window = app.world.resources.get(Window).?;
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

        _ = app
            .insertResource(ClearColor{})
            .addSystems(aya.Last, RenderClear);

        // fart();
    }
};

const zmesh = @import("zmesh");

fn fart() void {
    zmesh.init(aya.allocator);
    defer zmesh.deinit();

    const data = zmesh.io.parseAndLoadFile("/Users/mikedesaro/Desktop/Monkey.gltf") catch unreachable;
    defer zmesh.io.freeData(data);

    var mesh_indices = std.ArrayList(u32).init(aya.allocator);
    defer mesh_indices.deinit();
    var mesh_positions = std.ArrayList([3]f32).init(aya.allocator);
    defer mesh_positions.deinit();
    var mesh_normals = std.ArrayList([3]f32).init(aya.allocator);
    defer mesh_normals.deinit();

    zmesh.io.appendMeshPrimitive(
        data, // *zmesh.io.cgltf.Data
        0, // mesh index
        0, // gltf primitive index (submesh index)
        &mesh_indices,
        &mesh_positions,
        &mesh_normals, // normals (optional)
        null, // texcoords (optional)
        null, // tangents (optional)
    ) catch unreachable;

    std.debug.print("\ndata: {any}\n", .{mesh_positions.items});
}

const RenderClear = struct {
    pub fn run(window_res: Res(Window), clear_color_res: Res(ClearColor)) void {
        const window = window_res.getAssertExists();
        const clear_color = clear_color_res.getAssertExists();

        var pass_action = sokol.gfx.PassAction{};
        pass_action.colors[0] = .{
            .load_action = .CLEAR,
            .clear_value = .{ .r = clear_color.r, .g = clear_color.g, .b = clear_color.b, .a = clear_color.a },
        };

        const size = window.sizeInPixels();
        sokol.gfx.beginDefaultPass(pass_action, size.w, size.h);
        sokol.gfx.endPass();
        sokol.gfx.commit();
    }
};
