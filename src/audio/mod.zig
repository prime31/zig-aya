const std = @import("std");
const ma = @import("zaudio");
const aya = @import("../aya.zig");

pub const Sound = @import("sound.zig").Sound;
pub const SoundGroup = @import("sound_group.zig").SoundGroup;
pub const Sfxr = @import("sfxr.zig").Sfxr;

const internal = @import("../internal.zig");

pub const SoundConfig = struct {
    flags: ma.Sound.Flags = .{},
    group: ?SoundGroup = null,
};

const AudioFilter = @import("audio_filter.zig").AudioFilter;

var engine: *ma.Engine = undefined;
var audio_filter: AudioFilter = undefined;

pub fn init() void {
    ma.init(aya.mem.allocator);
    engine = ma.Engine.create(null) catch unreachable;
    audio_filter = AudioFilter.init(engine);
}

pub fn deinit() void {
    audio_filter.deinit();
    engine.destroy();
    ma.deinit();
}

pub fn loadSound(filepath: [:0]const u8, args: SoundConfig) Sound {
    if (internal.assets.tryGetSound(filepath)) |snd| return snd;

    const snd = engine.createSoundFromFile(filepath, .{ .flags = args.flags, .sgroup = if (args.group) |g| g.src else null }) catch unreachable;
    const sound = Sound{ .src = snd };
    internal.assets.putSound(filepath, sound);

    return sound;
}

pub fn loadSfxr() *Sfxr {
    return Sfxr.create(engine);
}

pub fn playOneShot(filepath: [:0]const u8, group: ?SoundGroup) void {
    engine.playSound(filepath, if (group) |g| g.src else null) catch unreachable;
}

pub fn createSoundGroup(flags: ma.Sound.Flags, parent: ?SoundGroup) SoundGroup {
    return .{
        .src = ma.SoundGroup.create(engine, flags, if (parent) |p| p.src else null),
    };
}

pub fn start() void {
    engine.start() catch unreachable;
}

pub fn stop() void {
    engine.stop() catch unreachable;
}

pub fn setVolume(volume: f32) void {
    engine.setVolume(volume) catch unreachable;
}
pub fn setGainDb(gain_db: f32) void {
    engine.setGainDb(gain_db) catch unreachable;
}

// pub fn updateAudioGraph() void {
//     const node = node: {
//         if (audio_filter.?.is_enabled == false)
//             break :node engine.getEndpointMut();
//         break :node audio_filter.?.getCurrentNode();
//     };

//     music.?.attachOutputBus(0, node, 0) catch unreachable;
//     noise_node.?.attachOutputBus(0, node, 0) catch unreachable;
//     snd1.?.attachOutputBus(0, node, 0) catch unreachable;
//     snd2.?.attachOutputBus(0, node, 0) catch unreachable;
//     snd3.?.attachOutputBus(0, node, 0) catch unreachable;
// }
