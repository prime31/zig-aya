const std = @import("std");
const ma = @import("zaudio");
const aya = @import("../aya.zig");

pub var engine: *ma.Engine = undefined;
pub var snd1: ?*ma.Sound = undefined;
pub var snd2: ?*ma.Sound = undefined;
pub var snd3: ?*ma.Sound = undefined;
pub var music: ?*ma.Sound = undefined;

pub fn init() void {
    ma.init(aya.mem.allocator);
    engine = ma.Engine.create(null) catch unreachable;
}

pub fn deinit() void {
    if (snd1) |s| s.destroy();
    if (snd2) |s| s.destroy();
    if (snd3) |s| s.destroy();
    if (music) |s| s.destroy();
    engine.destroy();
    ma.deinit();
}

pub fn start() void {
    snd1 = engine.createSoundFromFile("examples/assets/audio/drum_bass_hard.flac", .{}) catch unreachable;
    snd1.start() catch unreachable;

    snd2 = engine.createSoundFromFile("examples/assets/audio/loop_mika.flac", .{}) catch unreachable;
    // snd2.start() catch unreachable;

    snd3 = engine.createSoundFromFile("examples/assets/audio/tabla_tas1.flac", .{}) catch unreachable;
    snd3.start() catch unreachable;

    music = engine.createSoundFromFile(
        "examples/assets/audio/Broke For Free - Night Owl.mp3",
        .{ .flags = .{ .stream = true } },
    ) catch unreachable;
    music.setVolume(1.5);
    music.start() catch unreachable;
}
