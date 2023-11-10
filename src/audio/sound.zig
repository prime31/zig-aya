const std = @import("std");
const ma = @import("zaudio");
const aya = @import("../aya.zig");
const ig = aya.ig;
const internal = @import("../internal.zig");

pub const Sound = struct {
    src: *ma.Sound,

    pub fn deinit(self: Sound) void {
        if (internal.assets.releaseSound(self))
            self.src.destroy();
    }

    pub fn inspect(self: *Sound) void {
        igInspect(self);
    }

    pub fn start(self: *Sound) void {
        self.src.start() catch unreachable;
    }

    pub fn stop(self: *Sound) void {
        self.src.stop() catch unreachable;
    }

    pub fn isPlaying(self: *const Sound) bool {
        return self.src.isPlaying();
    }

    pub fn getTimeInPcmFrames(self: *const Sound) u64 {
        return self.src.getLengthInPcmFrames();
    }

    pub fn setLooping(self: *Sound, looping: bool) void {
        self.src.setLooping(looping);
    }

    pub fn isLooping(self: *const Sound) bool {
        return self.src.isLooping();
    }

    pub fn isAtEnd(self: *const Sound) bool {
        return self.src.isAtEnd();
    }

    pub fn seekToPcmFrame(self: *Sound, frame_index: u64) void {
        self.src.seekToPcmFrame(frame_index) catch unreachable;
    }

    pub fn setVolume(self: *Sound, volume: f32) void {
        self.src.setVolume(volume);
    }

    pub fn getVolume(self: *Sound) f32 {
        return self.src.getVolume();
    }

    pub fn setPan(self: *Sound, pan: f32) void {
        self.src.setPan(pan);
    }

    pub fn getPan(self: *Sound) f32 {
        return self.src.getPan();
    }

    pub fn setPanMode(self: *Sound, pan_mode: ma.PanMode) void {
        self.src.setPanMode(pan_mode);
    }

    pub fn getPanMode(self: *Sound) ma.PanMode {
        return self.src.getPanMode();
    }

    pub fn setPitch(self: *Sound, pitch: f32) void {
        self.src.setPitch(pitch);
    }

    pub fn getPitch(self: *Sound) f32 {
        return self.src.getPitch();
    }

    pub fn setAttenuationModel(self: *Sound, model: ma.AttenuationModel) void {
        self.src.setAttenuationModel(model);
    }

    pub fn getAttenuationModel(self: *const Sound) ma.AttenuationModel {
        return self.src.getAttenuationModel();
    }

    pub fn setPositioning(self: *Sound, pos: ma.Positioning) void {
        self.src.setPositioning(pos);
    }

    pub fn getPositioning(self: *const Sound) ma.Positioning {
        self.src.getPositioning();
    }

    pub fn setRolloff(self: *Sound, rolloff: f32) void {
        self.src.setRolloff(rolloff);
    }

    pub fn getRolloff(self: *const Sound) f32 {
        return self.src.getRolloff();
    }

    pub fn setMinGain(self: *Sound, min_gain: f32) void {
        self.src.setMinGain(min_gain);
    }

    pub fn getMinGain(self: *const Sound) f32 {
        return self.src.getMinGain();
    }

    pub fn setMaxGain(self: *Sound, max_gain: f32) void {
        self.src.setMaxGain(max_gain);
    }

    pub fn getMaxGain(self: *const Sound) f32 {
        return self.src.getMaxGain();
    }

    pub fn setMinDistance(self: *Sound, min_distance: f32) void {
        self.src.setMinDistance(min_distance);
    }

    pub fn getMinDistance(self: *const Sound) f32 {
        return self.src.getMinDistance();
    }

    pub fn setMaxDistance(self: *Sound, max_distance: f32) void {
        self.src.setMaxDistance(max_distance);
    }

    pub fn getMaxDistance(self: *const Sound) f32 {
        return self.src.getMaxDistance();
    }

    pub fn setDopplerFactor(self: *Sound, factor: f32) void {
        self.src.setDopplerFactor(factor);
    }

    pub fn getDopplerFactor(self: *const Sound) f32 {
        return self.src.getDopplerFactor();
    }

    pub fn setDirectionalAttenuationFactor(self: *Sound, factor: f32) void {
        self.src.setDirectionalAttenuationFactor(factor);
    }

    pub fn getDirectionalAttenuationFactor(self: *const Sound) f32 {
        return self.src.getDirectionalAttenuationFactor();
    }

    pub fn setFadeInPcmFrames(self: *Sound, volume_begin: f32, volume_end: f32, len_in_frames: u64) void {
        self.src.setFadeInPcmFrames(volume_begin, volume_end, len_in_frames);
    }

    pub fn setFadeInMilliseconds(self: *Sound, volume_begin: f32, volume_end: f32, len_in_ms: u64) void {
        self.src.setFadeInMilliseconds(volume_begin, volume_end, len_in_ms);
    }

    pub fn getCurrentFadeVolume(self: *const Sound) f32 {
        return self.src.getCurrentFadeVolume();
    }

    pub fn setStartTimeInPcmFrames(self: *Sound, abs_global_time_in_frames: u64) void {
        self.src.setStartTimeInPcmFrames(abs_global_time_in_frames);
    }

    pub fn setStartTimeInMilliseconds(self: *Sound, abs_global_time_in_ms: u64) void {
        self.src.setStartTimeInMilliseconds(abs_global_time_in_ms);
    }

    pub fn setStopTimeInPcmFrames(self: *Sound, abs_global_time_in_frames: u64) void {
        self.src.setStopTimeInPcmFrames(abs_global_time_in_frames);
    }

    pub fn setStopTimeInMilliseconds(self: *Sound, abs_global_time_in_ms: u64) void {
        self.src.setStopTimeInMilliseconds(abs_global_time_in_ms);
    }
};

fn igInspect(sound: *Sound) void {
    if (!ig.enabled) return;

    const title = ig.formatZ("Sound##{}", .{@intFromPtr(sound.src)});
    if (ig.igBegin(title, null, ig.ImGuiWindowFlags_None)) {
        defer ig.igEnd();

        var is_playing = sound.isPlaying();
        if (ig.igCheckbox("Is Playing", &is_playing)) {
            if (is_playing) sound.start() else sound.stop();
        }

        var volume = sound.getVolume();
        if (ig.sliderScalar("Volume", f32, .{ .v = &volume, .min = 0, .max = 2 }))
            sound.setVolume(volume);

        var pan = sound.getPan();
        if (ig.sliderScalar("Pan", f32, .{ .v = &pan, .min = -1, .max = 1 }))
            sound.setPan(pan);

        var pitch = sound.getPitch();
        if (ig.sliderScalar("Pitch", f32, .{ .v = &pitch, .min = 0, .max = 10 }))
            sound.setPitch(pitch);
    }
}
