const std = @import("std");
const ma = @import("zaudio");
const aya = @import("aya");
const ig = aya.ig;

var tabla: aya.audio.Sound = undefined;
var music: aya.audio.Sound = undefined;

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
}

fn shutdown() !void {
    tabla.deinit();
    music.deinit();
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

        // if (ig.igButton("Play SFXR Jump", .{})) {
        //     aya.audio.sfxr.?.loadPreset(.jump, 669);
        //     const sfxr_sound = aya.audio.sfxr.?.createSound();
        //     sfxr_sound.start() catch unreachable;
        // }

        // if (ig.igButton("Play SFXR Laser", .{})) {
        //     const sfxr_sound = aya.audio.sfxr.?.createSound();
        //     aya.audio.sfxr.?.loadPreset(.laser, 669);
        //     sfxr_sound.start() catch unreachable;
        // }

        // if (ig.igButton("Play SFXR PowerUp", .{})) {
        //     const sfxr_sound = aya.audio.sfxr.?.createSound();
        //     aya.audio.sfxr.?.loadPreset(.power_up, 669);
        //     sfxr_sound.start() catch unreachable;
        // }
    }
}

fn render() !void {
    if (aya.input.keyJustPressed(.a)) aya.audio.playOneShot("examples/assets/audio/tabla_tas1.flac", null);
    if (aya.input.keyJustPressed(.b)) tabla.start();
    // if (aya.input.keyJustPressed(.b)) aya.audio.snd3.?.start() catch unreachable;
    // if (aya.input.keyJustPressed(.c)) aya.audio.snd1.?.start() catch unreachable;
    // if (aya.input.keyJustPressed(.d)) aya.audio.snd2.?.start() catch unreachable;

    // if (aya.input.keyJustPressed(.e)) {
    //     const sound = aya.audio.engine.createSoundCopy(aya.audio.snd3.?, .{}, null) catch unreachable;
    //     sound.start() catch unreachable; // leaks
    // }

    aya.gfx.beginPass(.{});
    aya.gfx.draw.rect(aya.math.Vec2.init(50, 50), 200, 400, aya.math.Color.lime);
    aya.gfx.endPass();
}
