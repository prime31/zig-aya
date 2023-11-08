const std = @import("std");
const aya = @import("aya");
const ig = aya.ig;

pub fn main() !void {
    std.debug.print("\n", .{});
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
    });
}

fn init() !void {
    aya.audio.start();
}

fn update() !void {
    const audio_filter = &aya.audio.audio_filter.?;

    if (ig.igBegin("Audio Filter", null, ig.ImGuiWindowFlags_None)) {
        defer ig.igEnd();

        if (ig.igCheckbox("Enabled", &audio_filter.is_enabled))
            aya.audio.updateAudioGraph();

        if (!audio_filter.is_enabled) ig.igBeginDisabled(true);
        defer if (!audio_filter.is_enabled) ig.igEndDisabled();

        const selected_item = @intFromEnum(audio_filter.current_type);
        if (ig.beginCombo("Type", .{ .preview_value = aya.audio.AudioFilterType.names[selected_item] })) {
            for (aya.audio.AudioFilterType.names, 0..) |name, index| {
                if (ig.selectable(name, .{ .selected = (selected_item == index) }) and
                    selected_item != index)
                {
                    audio_filter.current_type = @as(aya.audio.AudioFilterType, @enumFromInt(index));
                    aya.audio.updateAudioGraph();
                }
            }
            ig.igEndCombo();
        }

        switch (aya.audio.audio_filter.?.current_type) {
            .lpf => {
                const config = &audio_filter.lpf.config;
                if (ig.sliderScalar("Cutoff", f64, .{
                    .v = &config.cutoff_frequency,
                    .min = aya.audio.min_filter_fequency,
                    .max = aya.audio.max_filter_fequency,
                })) {
                    audio_filter.lpf.node.reconfigure(config.*) catch unreachable;
                }
            },
            .hpf => {
                const config = &audio_filter.hpf.config;
                if (ig.sliderScalar("Cutoff", f64, .{
                    .v = &config.cutoff_frequency,
                    .min = aya.audio.min_filter_fequency,
                    .max = aya.audio.max_filter_fequency,
                    .cfmt = "%.1f Hz",
                })) {
                    audio_filter.hpf.node.reconfigure(config.*) catch unreachable;
                }
            },
            .notch => {
                const config = &audio_filter.notch.config;
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
                if (has_changed) audio_filter.notch.node.reconfigure(config.*) catch unreachable;
            },
            .peak => {
                const config = &audio_filter.peak.config;
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
                if (has_changed) audio_filter.peak.node.reconfigure(config.*) catch unreachable;
            },
            .loshelf => {
                const config = &audio_filter.loshelf.config;
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
                if (has_changed) audio_filter.loshelf.node.reconfigure(config.*) catch unreachable;
            },
            .hishelf => {
                const config = &audio_filter.hishelf.config;
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
                if (has_changed) audio_filter.hishelf.node.reconfigure(config.*) catch unreachable;
            },
            .delay => {
                const config = &audio_filter.delay.config;
                // if (ig.sliderScalar("Delay in Frames", u32, .{
                //     .v = &config.delay_in_frames,
                //     .min = 0,
                //     .max = 500,
                // })) audio_filter.delay.node.setWet(config.wet);
                if (ig.sliderScalar("Wet", f32, .{
                    .v = &config.wet,
                    .min = 0,
                    .max = 1,
                    .cfmt = "%.3f",
                })) audio_filter.delay.node.setWet(config.wet);
                if (ig.sliderScalar("Dry", f32, .{
                    .v = &config.dry,
                    .min = 0,
                    .max = 1,
                    .cfmt = "%.3f",
                })) audio_filter.delay.node.setDry(config.dry);
                if (ig.sliderScalar("Decay", f32, .{
                    .v = &config.decay,
                    .min = 0,
                    .max = 1,
                    .cfmt = "%.3f",
                })) audio_filter.delay.node.setDecay(config.decay);
            },
        }
    }
}

fn render() !void {
    if (aya.input.keyJustPressed(.a)) aya.audio.snd3.?.start() catch unreachable;
    if (aya.input.keyJustPressed(.b)) aya.audio.snd1.?.start() catch unreachable;
    if (aya.input.keyJustPressed(.c)) aya.audio.snd2.?.start() catch unreachable;

    aya.gfx.beginPass(.{});
    aya.gfx.draw.rect(aya.math.Vec2.init(50, 50), 200, 400, aya.math.Color.lime);
    aya.gfx.endPass();
}
