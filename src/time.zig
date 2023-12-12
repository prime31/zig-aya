const std = @import("std");
const sdl = @import("sdl");

const samples_for_avg = 5;

var fps_frames: u64 = 0;
var prev_time: u64 = 0;
var curr_time: u64 = 0;
var delta_time: f32 = 0;
var fps_last_update: u64 = 0;
var frames_per_second: u64 = 0;
var frame_count: u32 = 1;

pub fn tick() void {
    frame_count += 1;
    fps_frames += 1;
    curr_time = sdl.SDL_GetTicks();
    delta_time = @as(f32, @floatFromInt(curr_time - prev_time)) / 1000;
    prev_time = curr_time;

    const time_since_last = curr_time - fps_last_update;
    if (curr_time > fps_last_update + 1000) {
        frames_per_second = fps_frames * 1000 / time_since_last;
        fps_last_update = curr_time;
        fps_frames = 0;
    }
}

pub fn sleep(ms: u32) void {
    sdl.SDL_Delay(ms);
}

pub fn frames() u32 {
    return frame_count;
}

pub fn ticks() u64 {
    return sdl.SDL_GetTicks();
}

pub fn seconds() f32 {
    return @as(f32, @floatFromInt(sdl.SDL_GetTicks())) / 1000;
}

pub fn sinTime() f32 {
    return @sin(seconds());
}

pub fn dt() f32 {
    return delta_time;
}

pub fn fps() u64 {
    return frames_per_second;
}

pub fn now() u64 {
    return sdl.SDL_GetPerformanceCounter();
}

/// returns the time in milliseconds since the last call
pub fn laptime(last_time: *u64) f64 {
    var tmp = last_time;
    const now_time = now();

    const dtime: f64 = if (tmp.* != 0) {
        @as(f64, @floatFromInt(((now_time - tmp.*) * 1000.0) / @as(f64, @floatFromInt(sdl.SDL_GetPerformanceFrequency()))));
    } else 0;
    return dtime;
}

pub fn toSeconds(perf_counter_time: u64) f64 {
    return @as(f64, @floatFromInt(perf_counter_time)) / @as(f64, @floatFromInt(sdl.SDL_GetPerformanceFrequency()));
}

pub fn toMs(perf_counter_time: u64) f64 {
    return @as(f64, @floatFromInt(perf_counter_time)) * 1000 / @as(f64, @floatFromInt(sdl.SDL_GetPerformanceFrequency()));
}
