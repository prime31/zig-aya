const std = @import("std");
const ma = @import("zaudio");
const aya = @import("../aya.zig");
const ig = aya.ig;

const Sound = @import("sound.zig").Sound;
const SoundGroup = @import("sound_group.zig").SoundGroup;

const min_filter_fequency: f32 = 20.0;
const max_filter_fequency: f32 = 500.0;
const min_filter_q: f32 = 0.02;
const max_filter_q: f32 = 1.0;
const min_filter_gain: f32 = -20.0;
const max_filter_gain: f32 = 20.0;
const filter_order: u32 = 4;
const delay_in_seconds: f32 = 0.4;
const decay: f32 = 0.5; // Volume falloff for each echo

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

pub const AudioFilter = struct {
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

    pub fn init(engine: *ma.Engine) AudioFilter {
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
            @intFromFloat(delay_in_seconds * @as(f32, @floatFromInt(engine.getSampleRate()))),
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

        return af;
    }

    pub fn deinit(self: AudioFilter) void {
        self.lpf.node.destroy();
        self.hpf.node.destroy();
        self.notch.node.destroy();
        self.peak.node.destroy();
        self.loshelf.node.destroy();
        self.hishelf.node.destroy();
        self.delay.node.destroy();
    }

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
};

fn igInspect(filter: AudioFilter) void {
    if (!ig.enabled) return;

    if (ig.igBegin("Audio Filter", null, ig.ImGuiWindowFlags_None)) {
        defer ig.igEnd();

        // if (ig.igCheckbox("Enabled", &filter.is_enabled))
        //     aya.audio.updateAudioGraph();

        if (!filter.is_enabled) ig.igBeginDisabled(true);

        const selected_item = @intFromEnum(filter.current_type);
        if (ig.beginCombo("Type", .{ .preview_value = aya.audio.AudioFilterType.names[selected_item] })) {
            for (aya.audio.AudioFilterType.names, 0..) |name, index| {
                if (ig.selectable(name, .{ .selected = (selected_item == index) }) and
                    selected_item != index)
                {
                    filter.current_type = @as(aya.audio.AudioFilterType, @enumFromInt(index));
                    aya.audio.updateAudioGraph();
                }
            }
            ig.igEndCombo();
        }

        switch (aya.audio.audio_filter.?.current_type) {
            .lpf => {
                const config = &filter.lpf.config;
                if (ig.sliderScalar("Cutoff", f64, .{
                    .v = &config.cutoff_frequency,
                    .min = aya.audio.min_filter_fequency,
                    .max = aya.audio.max_filter_fequency,
                })) {
                    filter.lpf.node.reconfigure(config.*) catch unreachable;
                }
            },
            .hpf => {
                const config = &filter.hpf.config;
                if (ig.sliderScalar("Cutoff", f64, .{
                    .v = &config.cutoff_frequency,
                    .min = aya.audio.min_filter_fequency,
                    .max = aya.audio.max_filter_fequency,
                    .cfmt = "%.1f Hz",
                })) {
                    filter.hpf.node.reconfigure(config.*) catch unreachable;
                }
            },
            .notch => {
                const config = &filter.notch.config;
                var has_changed = false;
                if (ig.sliderScalar("Frequency", f64, .{
                    .v = &config.frequency,
                    .min = aya.audio.min_filter_fequency,
                    .max = aya.audio.max_filter_fequency,
                    .cfmt = "%.1f Hz",
                })) has_changed = true;
                if (ig.sliderScalar("Q", f64, .{
                    .v = &config.q,
                    .min = aya.audio.min_filter_q,
                    .max = aya.audio.max_filter_q,
                    .cfmt = "%.3f",
                })) has_changed = true;
                if (has_changed) filter.notch.node.reconfigure(config.*) catch unreachable;
            },
            .peak => {
                const config = &filter.peak.config;
                var has_changed = false;
                if (ig.sliderScalar("Gain", f64, .{
                    .v = &config.gain_db,
                    .min = aya.audio.min_filter_gain,
                    .max = aya.audio.max_filter_gain,
                    .cfmt = "%.1f dB",
                })) has_changed = true;
                if (ig.sliderScalar("Frequency", f64, .{
                    .v = &config.frequency,
                    .min = aya.audio.min_filter_fequency,
                    .max = aya.audio.max_filter_fequency,
                    .cfmt = "%.1f Hz",
                })) has_changed = true;
                if (ig.sliderScalar("Q", f64, .{
                    .v = &config.q,
                    .min = aya.audio.min_filter_q,
                    .max = aya.audio.max_filter_q,
                    .cfmt = "%.3f",
                })) has_changed = true;
                if (has_changed) filter.peak.node.reconfigure(config.*) catch unreachable;
            },
            .loshelf => {
                const config = &filter.loshelf.config;
                var has_changed = false;
                if (ig.sliderScalar("Gain", f64, .{
                    .v = &config.gain_db,
                    .min = aya.audio.min_filter_gain,
                    .max = aya.audio.max_filter_gain,
                    .cfmt = "%.1f dB",
                })) has_changed = true;
                if (ig.sliderScalar("Frequency", f64, .{
                    .v = &config.frequency,
                    .min = aya.audio.min_filter_fequency,
                    .max = aya.audio.max_filter_fequency,
                    .cfmt = "%.1f Hz",
                })) has_changed = true;
                if (ig.sliderScalar("Slope", f64, .{
                    .v = &config.shelf_slope,
                    .min = aya.audio.min_filter_q,
                    .max = aya.audio.max_filter_q,
                    .cfmt = "%.3f",
                })) has_changed = true;
                if (has_changed) filter.loshelf.node.reconfigure(config.*) catch unreachable;
            },
            .hishelf => {
                const config = &filter.hishelf.config;
                var has_changed = false;
                if (ig.sliderScalar("Gain", f64, .{
                    .v = &config.gain_db,
                    .min = aya.audio.min_filter_gain,
                    .max = aya.audio.max_filter_gain,
                    .cfmt = "%.1f dB",
                })) has_changed = true;
                if (ig.sliderScalar("Frequency", f64, .{
                    .v = &config.frequency,
                    .min = aya.audio.min_filter_fequency,
                    .max = aya.audio.max_filter_fequency,
                    .cfmt = "%.1f Hz",
                })) has_changed = true;
                if (ig.sliderScalar("Slope", f64, .{
                    .v = &config.shelf_slope,
                    .min = aya.audio.min_filter_q,
                    .max = aya.audio.max_filter_q,
                    .cfmt = "%.3f",
                })) has_changed = true;
                if (has_changed) filter.hishelf.node.reconfigure(config.*) catch unreachable;
            },
            .delay => {
                const config = &filter.delay.config;
                if (ig.sliderScalar("Wet", f32, .{
                    .v = &config.wet,
                    .min = 0,
                    .max = 1,
                    .cfmt = "%.3f",
                })) filter.delay.node.setWet(config.wet);
                if (ig.sliderScalar("Dry", f32, .{
                    .v = &config.dry,
                    .min = 0,
                    .max = 1,
                    .cfmt = "%.3f",
                })) filter.delay.node.setDry(config.dry);
                if (ig.sliderScalar("Decay", f32, .{
                    .v = &config.decay,
                    .min = 0,
                    .max = 1,
                    .cfmt = "%.3f",
                })) filter.delay.node.setDecay(config.decay);
            },
        }

        if (!filter.is_enabled) ig.igEndDisabled();
    }
}
