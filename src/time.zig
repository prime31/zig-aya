const std = @import("std");
const sdl = @import("sdl");

const samples_for_avg = 5;

var fps_frames: u64 = 0;
var prev_time: u64 = 0;
var curr_time: u64 = 0;
var fps_last_update: u64 = 0;
var frames_per_seconds: u64 = 0;
var frame_count: u32 = 1;
var ts: Timestep = undefined;

pub fn init(update_rate: f64) void {
    ts = Timestep.init(update_rate);
}

fn updateFps() void {
    frame_count += 1;
    fps_frames += 1;
    prev_time = curr_time;
    curr_time = sdl.SDL_GetTicks();

    const time_since_last = curr_time - fps_last_update;
    if (curr_time > fps_last_update + 1000) {
        frames_per_seconds = fps_frames * 1000 / time_since_last;
        fps_last_update = curr_time;
        fps_frames = 0;
    }
}

pub fn tick() void {
    updateFps();
    ts.tick();
}

pub fn sleep(ms: u32) void {
    sdl.SDL_Delay(ms);
}

pub fn frames() u32 {
    return frame_count;
}

pub fn ticks() u32 {
    return sdl.SDL_GetTicks();
}

pub fn seconds() f32 {
    return @as(f32, @floatFromInt(sdl.SDL_GetTicks())) / 1000;
}

pub fn fps() u64 {
    return frames_per_seconds;
}

pub fn dt() f32 {
    return ts.fixed_deltatime;
}

pub fn rawDeltaTime() f32 {
    return ts.raw_deltatime;
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

/// forces a resync of the timing code. Useful after some slower operations such as level loads or window resizes
pub fn resync() void {
    ts.resync = true;
    ts.prev_frame_time = sdl.SDL_GetPerformanceCounter() + @as(u64, @intFromFloat(ts.fixed_deltatime));
}

// converted from Tyler Glaiel's: https://github.com/TylerGlaiel/FrameTimingControl/blob/master/frame_timer.cpp
const Timestep = struct {
    // compute how many ticks one update should be
    fixed_deltatime: f32,
    desired_frametime: i32,
    raw_deltatime: f32 = 0,

    // these are to snap deltaTime to vsync values if it's close enough
    vsync_maxerror: u64,
    snap_frequencies: [5]i32 = undefined,
    prev_frame_time: u64,
    frame_accumulator: i64 = 0,
    resync: bool = false,
    // time_averager: utils.Ring_Buffer(u64, samples_for_avg),
    time_averager: [samples_for_avg]i32 = undefined,

    pub fn init(update_rate: f64) Timestep {
        var timestep = Timestep{
            .fixed_deltatime = 1 / @as(f32, @floatCast(update_rate)),
            .desired_frametime = @as(i32, @intFromFloat(@as(f64, @floatFromInt(sdl.SDL_GetPerformanceFrequency())) / update_rate)),
            .vsync_maxerror = sdl.SDL_GetPerformanceFrequency() / 5000,
            .prev_frame_time = sdl.SDL_GetPerformanceCounter(),
        };

        // TODO:
        // utils.ring_buffer_fill(&timestep.time_averager, timestep.desired_frametime);
        timestep.time_averager = [samples_for_avg]i32{ timestep.desired_frametime, timestep.desired_frametime, timestep.desired_frametime, timestep.desired_frametime, timestep.desired_frametime };

        const time_60hz = @as(i32, @intFromFloat(@as(f64, @floatFromInt(sdl.SDL_GetPerformanceFrequency())) / 60));
        timestep.snap_frequencies[0] = time_60hz; // 60fps
        timestep.snap_frequencies[1] = time_60hz * 2; // 30fps
        timestep.snap_frequencies[2] = time_60hz * 3; // 20fps
        timestep.snap_frequencies[3] = time_60hz * 4; // 15fps
        timestep.snap_frequencies[4] = @divTrunc(time_60hz + 1, 2); // 120fps

        return timestep;
    }

    pub fn tick(self: *Timestep) void {
        // frame timer
        const current_frame_time = sdl.SDL_GetPerformanceCounter();
        const delta_u32 = @as(u32, @truncate(current_frame_time - self.prev_frame_time));
        var delta_time = @as(i32, @intCast(delta_u32));
        self.prev_frame_time = current_frame_time;

        // handle unexpected timer anomalies (overflow, extra slow frames, etc)
        if (delta_time > self.desired_frametime * 8) delta_time = self.desired_frametime;
        if (delta_time < 0) delta_time = 0;

        // vsync time snapping
        for (self.snap_frequencies) |snap| {
            if (@abs(delta_time - snap) < self.vsync_maxerror) {
                delta_time = snap;
                break;
            }
        }

        // delta time averaging
        var dt_avg = delta_time;
        var i: usize = 0;
        while (i < samples_for_avg - 1) : (i += 1) {
            self.time_averager[i] = self.time_averager[i + 1];
            dt_avg += self.time_averager[i];
        }

        self.time_averager[samples_for_avg - 1] = delta_time;
        delta_time = @divTrunc(dt_avg, samples_for_avg);
        self.raw_deltatime = @as(f32, @floatFromInt(delta_u32)) / @as(f32, @floatFromInt(sdl.SDL_GetPerformanceFrequency()));

        // add to the accumulator
        self.frame_accumulator += delta_time;

        // spiral of death protection
        if (self.frame_accumulator > self.desired_frametime * 8) self.resync = true;

        // TODO: why does vsync not work on x64 macs all of a sudden?!?! forced sleep.
        // if (@import("builtin").os.tag == .macos and @import("builtin").target.cpu.arch == std.Target.Cpu.Arch.x86_64) {
        //     const elapsed = self.desired_frametime - delta_time;
        //     if (elapsed > 0) {
        //         const diff = @as(f32, @floatFromInt(elapsed)) / @as(f32, @floatFromInt(sdl.SDL_GetPerformanceFrequency()));
        //         std.time.sleep(@as(u64, @intFromFloat(diff * 1000000000)));
        //     }
        // }

        // TODO: should we zero out the frame_accumulator here? timer resync is requested so reset all state
        if (self.resync) {
            self.frame_accumulator = self.desired_frametime;
            delta_time = self.desired_frametime;
            self.resync = false;
        }
    }
};
