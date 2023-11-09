const std = @import("std");
const ma = @import("zaudio");
const aya = @import("../aya.zig");
const SfxrDataSource = @import("sfxr.zig").Sfxr;

pub var engine: *ma.Engine = undefined;
pub var snd1: ?*ma.Sound = null;
pub var snd2: ?*ma.Sound = null;
pub var snd3: ?*ma.Sound = null;
pub var music: ?*ma.Sound = null;
pub var sfxr: ?*SfxrDataSource = null;
pub var audio_filter: ?AudioFilter = null;
pub var noise_data_source: ?*ma.Noise = null;
pub var noise_node: ?*ma.DataSourceNode = null;

pub const min_filter_fequency: f32 = 20.0;
pub const max_filter_fequency: f32 = 500.0;
pub const min_filter_q: f32 = 0.02;
pub const max_filter_q: f32 = 1.0;
pub const min_filter_gain: f32 = -20.0;
pub const max_filter_gain: f32 = 20.0;
pub const filter_order: u32 = 4;
pub const delay_in_frames: u32 = 100;
pub const decay: f32 = 0;

pub fn init() void {
    ma.init(aya.mem.allocator);
    engine = ma.Engine.create(null) catch unreachable;
}

pub fn deinit() void {
    if (snd1) |s| s.destroy();
    if (snd2) |s| s.destroy();
    if (snd3) |s| s.destroy();
    if (music) |s| s.destroy();
    if (sfxr) |s| s.destroy();
    if (audio_filter) |af| af.destroy();
    if (noise_data_source) |n| n.destroy();
    if (noise_node) |n| n.destroy();

    engine.destroy();
    ma.deinit();
}

pub const AudioFilterType = enum {
    lpf,
    hpf,
    notch,
    peak,
    loshelf,
    hishelf,
    delay,

    pub const names = [_][:0]const u8{
        "Low-Pass Filter",
        "High-Pass Filter",
        "Notch Filter",
        "Peak Filter",
        "Low Shelf Filter",
        "High Shelf Filter",
        "Delay Filter",
    };
};

const AudioFilter = struct {
    current_type: AudioFilterType = .lpf,
    is_enabled: bool = false,

    lpf: struct {
        config: ma.LpfConfig,
        node: *ma.LpfNode,
    },
    hpf: struct {
        config: ma.HpfConfig,
        node: *ma.HpfNode,
    },
    notch: struct {
        config: ma.NotchConfig,
        node: *ma.NotchNode,
    },
    peak: struct {
        config: ma.PeakConfig,
        node: *ma.PeakNode,
    },
    loshelf: struct {
        config: ma.LoshelfConfig,
        node: *ma.LoshelfNode,
    },
    hishelf: struct {
        config: ma.HishelfConfig,
        node: *ma.HishelfNode,
    },
    delay: struct {
        config: ma.DelayConfig,
        node: *ma.DelayNode,
    },

    fn getCurrentNode(filter: AudioFilter) *ma.Node {
        return switch (filter.current_type) {
            .lpf => filter.lpf.node.asNodeMut(),
            .hpf => filter.hpf.node.asNodeMut(),
            .notch => filter.notch.node.asNodeMut(),
            .peak => filter.peak.node.asNodeMut(),
            .loshelf => filter.loshelf.node.asNodeMut(),
            .hishelf => filter.hishelf.node.asNodeMut(),
            .delay => filter.delay.node.asNodeMut(),
        };
    }

    fn destroy(filter: AudioFilter) void {
        filter.lpf.node.destroy();
        filter.hpf.node.destroy();
        filter.notch.node.destroy();
        filter.peak.node.destroy();
        filter.loshelf.node.destroy();
        filter.hishelf.node.destroy();
        filter.delay.node.destroy();
    }
};

pub fn start() void {
    snd1 = engine.createSoundFromFile("examples/assets/audio/drum_bass_hard.flac", .{}) catch unreachable;
    snd1.?.start() catch unreachable;

    snd2 = engine.createSoundFromFile("examples/assets/audio/loop_mika.flac", .{}) catch unreachable;
    // snd2.start() catch unreachable;

    snd3 = engine.createSoundFromFile("examples/assets/audio/tabla_tas1.flac", .{}) catch unreachable;
    snd3.?.start() catch unreachable;

    music = engine.createSoundFromFile(
        "examples/assets/audio/Broke For Free - Night Owl.mp3",
        .{ .flags = .{ .stream = true } },
    ) catch unreachable;
    music.?.setVolume(1.5);
    music.?.start() catch unreachable;

    audio_filter = audio_filter: {
        const lpf_config = ma.LpfNode.Config.init(
            engine.getChannels(),
            engine.getSampleRate(),
            min_filter_fequency,
            filter_order,
        );
        const hpf_config = ma.HpfNode.Config.init(
            engine.getChannels(),
            engine.getSampleRate(),
            min_filter_fequency,
            filter_order,
        );
        const notch_config = ma.NotchNode.Config.init(
            engine.getChannels(),
            engine.getSampleRate(),
            min_filter_q,
            min_filter_fequency,
        );
        const peak_config = ma.PeakNode.Config.init(
            engine.getChannels(),
            engine.getSampleRate(),
            min_filter_gain,
            min_filter_q,
            min_filter_fequency,
        );
        const loshelf_config = ma.LoshelfNode.Config.init(
            engine.getChannels(),
            engine.getSampleRate(),
            min_filter_gain,
            min_filter_q,
            min_filter_fequency,
        );
        const hishelf_config = ma.HishelfNode.Config.init(
            engine.getChannels(),
            engine.getSampleRate(),
            min_filter_gain,
            min_filter_q,
            min_filter_fequency,
        );
        const delay_config = ma.DelayNode.Config.init(
            engine.getChannels(),
            engine.getSampleRate(),
            delay_in_frames,
            decay,
        );

        const af = AudioFilter{
            .lpf = .{
                .config = lpf_config.lpf,
                .node = engine.createLpfNode(lpf_config) catch unreachable,
            },
            .hpf = .{
                .config = hpf_config.hpf,
                .node = engine.createHpfNode(hpf_config) catch unreachable,
            },
            .notch = .{
                .config = notch_config.notch,
                .node = engine.createNotchNode(notch_config) catch unreachable,
            },
            .peak = .{
                .config = peak_config.peak,
                .node = engine.createPeakNode(peak_config) catch unreachable,
            },
            .loshelf = .{
                .config = loshelf_config.loshelf,
                .node = engine.createLoshelfNode(loshelf_config) catch unreachable,
            },
            .hishelf = .{
                .config = hishelf_config.hishelf,
                .node = engine.createHishelfNode(hishelf_config) catch unreachable,
            },
            .delay = .{
                .config = delay_config.delay,
                .node = engine.createDelayNode(delay_config) catch unreachable,
            },
        };

        af.lpf.node.attachOutputBus(0, engine.getEndpointMut(), 0) catch unreachable;
        af.hpf.node.attachOutputBus(0, engine.getEndpointMut(), 0) catch unreachable;
        af.notch.node.attachOutputBus(0, engine.getEndpointMut(), 0) catch unreachable;
        af.peak.node.attachOutputBus(0, engine.getEndpointMut(), 0) catch unreachable;
        af.loshelf.node.attachOutputBus(0, engine.getEndpointMut(), 0) catch unreachable;
        af.hishelf.node.attachOutputBus(0, engine.getEndpointMut(), 0) catch unreachable;
        af.delay.node.attachOutputBus(0, engine.getEndpointMut(), 0) catch unreachable;

        break :audio_filter af;
    };

    // Noise generator
    const noise_config = ma.Noise.Config.init(
        .float32,
        engine.getChannels(),
        .pink,
        123,
        0.25,
    );
    noise_data_source = ma.Noise.create(noise_config) catch unreachable;
    noise_node = engine.createDataSourceNode(
        ma.DataSourceNode.Config.init(noise_data_source.?.asDataSourceMut()),
    ) catch unreachable;
    noise_node.?.setState(.stopped) catch unreachable;

    sfxr = SfxrDataSource.create(engine);
    const sfxr_sound = sfxr.?.createSound();
    sfxr.?.loadPreset(.jump, 669);
    sfxr_sound.start() catch unreachable;
}

pub fn updateAudioGraph() void {
    const node = node: {
        if (audio_filter.?.is_enabled == false)
            break :node engine.getEndpointMut();
        break :node audio_filter.?.getCurrentNode();
    };

    music.?.attachOutputBus(0, node, 0) catch unreachable;
    // noise_node.?.attachOutputBus(0, node, 0) catch unreachable;
    snd1.?.attachOutputBus(0, node, 0) catch unreachable;
    snd2.?.attachOutputBus(0, node, 0) catch unreachable;
    snd3.?.attachOutputBus(0, node, 0) catch unreachable;
}
