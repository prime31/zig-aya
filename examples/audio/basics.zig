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
    if (ig.igBegin("Audio Shit", null, ig.ImGuiWindowFlags_None)) {
        defer ig.igEnd();

        var is_enabled = aya.audio.noise_node.?.getState() == .started;
        if (ig.igCheckbox("Enabled", &is_enabled)) {
            if (is_enabled) {
                aya.audio.noise_node.?.setState(.started) catch unreachable;
            } else aya.audio.noise_node.?.setState(.stopped) catch unreachable;
        }

        if (ig.igButton("Update Audio Graph", .{ .x = 0, .y = 0 })) aya.audio.updateAudioGraph();

        switch (aya.audio.audio_filter.?.current_type) {
            .lpf => {
                const config = &aya.audio.audio_filter.?.lpf.config;
                if (ig.igSliderScalar(
                    "Cutuff",
                    ig.ImGuiDataType_Float,
                    &config.cutoff_frequency,
                    &aya.audio.min_filter_fequency,
                    &aya.audio.max_filter_fequency,
                    "%.1f Hz",
                    ig.ImGuiSliderFlags_None,
                )) {
                    aya.audio.audio_filter.?.lpf.node.reconfigure(config.*) catch unreachable;
                }
            },
            else => {},
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
