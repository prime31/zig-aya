const std = @import("std");
const math = @import("math/math.zig");

const samples_for_avg = 5;

pub const Time = struct {
    start: i64,
    fps_frames: u32 = 0,
    prev_time: i64 = 0,
    curr_time: i64 = 0,
    fps_last_update: i64 = 0,
    frames_per_seconds: i64 = 0,
    frame_count: u32 = 1,

    pub fn init() Time {
        return .{
            .start = std.time.milliTimestamp(),
        };
    }

    fn updateFps(self: *Time) void {
        self.frame_count += 1;
        self.fps_frames += 1;
        self.prev_time = self.curr_time;
        self.curr_time = std.time.milliTimestamp();

        const time_since_last = self.curr_time - self.fps_last_update;
        if (self.curr_time > self.fps_last_update + 1000) {
            self.frames_per_seconds = @divTrunc(@intCast(i64, self.fps_frames) * 1000, time_since_last);
            self.fps_last_update = self.curr_time;
            self.fps_frames = 0;
        }
    }

    pub fn tick(self: *Time) void {
        self.updateFps();
    }

    pub fn sleep(self: Time, ms: u32) void {
        std.time.sleep(ms * std.time.ns_per_ms);
    }

    pub fn frames(self: Time) u32 {
        return self.frame_count;
    }

    pub fn seconds(self: Time) f32 {
        return @intToFloat(f32, std.time.milliTimestamp() - self.start) / std.time.ms_per_s;
    }

    pub fn fps(self: Time) u32 {
        return self.frames_per_seconds;
    }

    pub fn dt(self: Time) f32 {
        return self.timestep.fixed_deltatime;
    }

    pub fn now(self: Time) i64 {
        return std.time.milliTimestamp();
    }
};
