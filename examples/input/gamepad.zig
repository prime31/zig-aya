const std = @import("std");
const aya = @import("aya");
const wgpu = aya.wgpu;
const ig = aya.ig;

const Color = aya.math.Color;

pub fn main() !void {
    std.debug.print("\n", .{});
    try aya.run(.{
        .update = update,
        .render = render,
    });
}

fn update() !void {
    for (aya.getEventReader(aya.gamepad.GamepadConnectionEvent).read()) |evt| {
        std.debug.print("gamepad connected: {}\n", .{evt});
    }
}

fn render() !void {
    // @panic("TODO");
    // aya.debug.drawTextFmt("fps: {d:0.4}, dt: {d:0.4}", .{ aya.time.fps(), aya.time.rawDeltaTime() }, .{ .x = 10, .y = 20 }, null);
    // aya.debug.drawHollowCircle(.{ .x = 600, .y = 600 }, 30, 4, Color.dark_purple);

    // aya.gfx.beginPass(.{});
    // aya.gfx.draw.rect(aya.math.Vec2.init(50, 50), 200, 400, Color.lime);
    // aya.gfx.endPass();

    // while (aya.gamepad.nextGamepad()) |pad| {
    //     std.debug.print("pad: {}\n", .{pad.getAxis(.left_trigger)});
    // }

    var surface_texture: wgpu.SurfaceTexture = undefined;
    aya.gctx.surface.getCurrentTexture(&surface_texture);
    defer if (surface_texture.texture) |t| t.release();

    const texture_view = surface_texture.texture.?.createView(null);
    defer texture_view.release();

    var command_encoder = aya.gctx.device.createCommandEncoder(&.{ .label = "Command Encoder" });

    // begin the render pass
    var pass = command_encoder.beginRenderPass(&.{
        .label = "Render Pass Encoder",
        .color_attachment_count = 1,
        .color_attachments = &.{
            .view = texture_view,
            .load_op = .clear,
            .store_op = .store,
            .clear_value = .{ .r = 0.1, .g = 0.2, .b = 0.3, .a = 1.0 },
        },
    });
    pass.end();
    pass.release();

    // TODO: move this in aya
    aya.ig.sdl.draw(aya.gctx, command_encoder, texture_view);

    var command_buffer = command_encoder.finish(&.{ .label = "Command buffer" });
    aya.gctx.submit(&.{command_buffer});
    aya.gctx.surface.present();
}
