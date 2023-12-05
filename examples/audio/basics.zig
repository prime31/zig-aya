const std = @import("std");
const ma = @import("zaudio");
const aya = @import("aya");
const wgpu = aya.wgpu;
const ig = aya.ig;

var tabla: aya.audio.Sound = undefined;
var music: aya.audio.Sound = undefined;
var sfxr: *aya.audio.Sfxr = undefined;

pub fn main() !void {
    std.debug.print("\n", .{});
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
        .shutdown = shutdown,
    });
}

fn init() !void {
    tabla = aya.audio.loadSound("examples/assets/audio/tabla_tas1.flac", .{});
    music = aya.audio.loadSound("examples/assets/audio/Broke For Free - Night Owl.mp3", .{ .flags = .{ .stream = true } });
    sfxr = aya.audio.loadSfxr();
}

fn shutdown() !void {
    tabla.deinit();
    music.deinit();
    sfxr.destroy();
}

fn update() !void {
    tabla.inspect();
    music.inspect();

    if (ig.igBegin("Audio Buttons", null, ig.ImGuiWindowFlags_None)) {
        defer ig.igEnd();

        if (ig.igButton("One Shot Tabla", .{}))
            aya.audio.playOneShot("examples/assets/audio/tabla_tas1.flac", null);

        if (music.isPlaying()) {
            if (ig.igButton("Stop Music", .{ .x = 100 }))
                music.stop();
        } else {
            if (ig.igButton("Start Music", .{ .x = 100 }))
                music.start();
        }

        if (ig.igButton("Play SFXR Jump", .{})) {
            sfxr.loadPreset(.jump, 669);
            const sfxr_sound = sfxr.createSound();
            sfxr_sound.start() catch unreachable;
        }

        if (ig.igButton("Play SFXR Laser", .{})) {
            const sfxr_sound = sfxr.createSound();
            sfxr.loadPreset(.laser, 669);
            sfxr_sound.start() catch unreachable;
        }

        if (ig.igButton("Play SFXR PowerUp", .{})) {
            const sfxr_sound = sfxr.createSound();
            sfxr.loadPreset(.power_up, 669);
            sfxr_sound.start() catch unreachable;
        }
    }
}

fn render() !void {
    if (aya.kb.justPressed(.a)) aya.audio.playOneShot("examples/assets/audio/tabla_tas1.flac", null);
    if (aya.kb.justPressed(.b)) tabla.start();
    // if (aya.input.keyJustPressed(.b)) aya.audio.snd3.?.start() catch unreachable;
    // if (aya.input.keyJustPressed(.c)) aya.audio.snd1.?.start() catch unreachable;
    // if (aya.input.keyJustPressed(.d)) aya.audio.snd2.?.start() catch unreachable;

    // if (aya.input.keyJustPressed(.e)) {
    //     const sound = aya.audio.engine.createSoundCopy(aya.audio.snd3.?, .{}, null) catch unreachable;
    //     sound.start() catch unreachable; // leaks
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

    // aya.gfx.beginPass(.{});
    // aya.gfx.draw.rect(aya.math.Vec2.init(50, 50), 200, 400, aya.math.Color.lime);
    // aya.gfx.endPass();
}
