const std = @import("std");
const ma = @import("zaudio");
const aya = @import("../aya.zig");
const ig = aya.ig;

pub const SoundGroup = struct {
    src: *ma.SoundGroup,

    pub fn deinit(self: SoundGroup) void {
        self.src.destroy();
    }

    pub fn inspect(self: *SoundGroup) void {
        igInspect(self);
    }

    pub fn start(self: *SoundGroup) void {
        self.src.start() catch unreachable;
    }

    pub fn stop(self: *SoundGroup) void {
        self.src.stop() catch unreachable;
    }

    pub fn isPlaying(self: *const SoundGroup) bool {
        return self.src.isPlaying();
    }

    pub fn getTimeInPcmFrames(self: *const SoundGroup) u64 {
        return self.src.getLengthInPcmFrames();
    }

    pub fn setLooping(self: *SoundGroup, looping: bool) void {
        self.src.setLooping(looping);
    }

    pub fn isLooping(self: *const SoundGroup) bool {
        return self.src.isLooping();
    }

    pub fn isAtEnd(self: *const SoundGroup) bool {
        return self.src.isAtEnd();
    }

    pub fn seekToPcmFrame(self: *SoundGroup, frame_index: u64) void {
        self.src.seekToPcmFrame(frame_index) catch unreachable;
    }

    pub fn setVolume(self: *const SoundGroup, volume: f32) void {
        self.src.setVolume(volume);
    }

    pub fn getVolume(self: *const SoundGroup) f32 {
        return self.src.getVolume();
    }

    pub fn setPan(self: *const SoundGroup, pan: f32) void {
        self.src.setPan(pan);
    }

    pub fn getPan(self: *const SoundGroup) f32 {
        return self.src.getPan();
    }

    pub fn setPanMode(self: *const SoundGroup, pan_mode: ma.PanMode) void {
        self.src.setPanMode(pan_mode);
    }

    pub fn getPanMode(self: *const SoundGroup) ma.PanMode {
        return self.src.getPanMode();
    }

    pub fn setPitch(self: *const SoundGroup, pitch: f32) void {
        self.src.setPitch(pitch);
    }

    pub fn getPitch(self: *const SoundGroup) f32 {
        return self.src.getPitch();
    }

    pub fn setAttenuationModel(self: *SoundGroup, model: ma.AttenuationModel) void {
        self.src.setAttenuationModel(model);
    }

    pub fn getAttenuationModel(self: *const SoundGroup) ma.AttenuationModel {
        return self.src.getAttenuationModel();
    }

    pub fn setPositioning(self: *SoundGroup, pos: ma.Positioning) void {
        self.src.setPositioning(pos);
    }

    pub fn getPositioning(self: *const SoundGroup) ma.Positioning {
        self.src.getPositioning();
    }

    pub fn setRolloff(self: *SoundGroup, rolloff: f32) void {
        self.src.setRolloff(rolloff);
    }

    pub fn getRolloff(self: *const SoundGroup) f32 {
        return self.src.getRolloff();
    }

    pub fn setMinGain(self: *SoundGroup, min_gain: f32) void {
        self.src.setMinGain(min_gain);
    }

    pub fn getMinGain(self: *const SoundGroup) f32 {
        return self.src.getMinGain();
    }

    pub fn setMaxGain(self: *SoundGroup, max_gain: f32) void {
        self.src.setMaxGain(max_gain);
    }

    pub fn getMaxGain(self: *const SoundGroup) f32 {
        return self.src.getMaxGain();
    }

    pub fn setMinDistance(self: *SoundGroup, min_distance: f32) void {
        self.src.setMinDistance(min_distance);
    }

    pub fn getMinDistance(self: *const SoundGroup) f32 {
        return self.src.getMinDistance();
    }

    pub fn setMaxDistance(self: *SoundGroup, max_distance: f32) void {
        self.src.setMaxDistance(max_distance);
    }

    pub fn getMaxDistance(self: *const SoundGroup) f32 {
        return self.src.getMaxDistance();
    }

    pub fn setDopplerFactor(self: *SoundGroup, factor: f32) void {
        self.src.setDopplerFactor(factor);
    }

    pub fn getDopplerFactor(self: *const SoundGroup) f32 {
        return self.src.getDopplerFactor();
    }

    pub fn setDirectionalAttenuationFactor(self: *SoundGroup, factor: f32) void {
        self.src.setDirectionalAttenuationFactor(factor);
    }

    pub fn getDirectionalAttenuationFactor(self: *const SoundGroup) f32 {
        return self.src.getDirectionalAttenuationFactor();
    }

    pub fn setFadeInPcmFrames(self: *SoundGroup, volume_begin: f32, volume_end: f32, len_in_frames: u64) void {
        self.src.setFadeInPcmFrames(volume_begin, volume_end, len_in_frames);
    }

    pub fn setFadeInMilliseconds(self: *SoundGroup, volume_begin: f32, volume_end: f32, len_in_ms: u64) void {
        self.src.setFadeInMilliseconds(volume_begin, volume_end, len_in_ms);
    }

    pub fn getCurrentFadeVolume(self: *const SoundGroup) f32 {
        return self.src.getCurrentFadeVolume();
    }

    pub fn setStartTimeInPcmFrames(self: *SoundGroup, abs_global_time_in_frames: u64) void {
        self.src.setStartTimeInPcmFrames(abs_global_time_in_frames);
    }

    pub fn setStartTimeInMilliseconds(self: *SoundGroup, abs_global_time_in_ms: u64) void {
        self.src.setStartTimeInMilliseconds(abs_global_time_in_ms);
    }

    pub fn setStopTimeInPcmFrames(self: *SoundGroup, abs_global_time_in_frames: u64) void {
        self.src.setStopTimeInPcmFrames(abs_global_time_in_frames);
    }

    pub fn setStopTimeInMilliseconds(self: *SoundGroup, abs_global_time_in_ms: u64) void {
        self.src.setStopTimeInMilliseconds(abs_global_time_in_ms);
    }
};

fn igInspect(sound: *SoundGroup) void {
    if (!ig.enabled) return;

    const title = ig.formatZ("Sound Group##{}", .{@intFromPtr(sound.src)});
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
