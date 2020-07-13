const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;

pub const LibType = enum(i32) {
    static,
    dynamic, // requires DYLD_LIBRARY_PATH to point to the dylib path
    exe_compiled,
};

/// test builder. This build file is meant to be included in an executable project. This build method is here
/// only for local testing.
pub fn build(b: *Builder) void {
    const exe = b.addStaticLibrary("JunkLib", null);
    linkArtifact(b, exe, b.standardTargetOptions(.{}), .static);
    exe.install();
}

/// rel_path is used to add package paths. It should be the the same path used to include this build file
pub fn linkArtifact(b: *Builder, artifact: *std.build.LibExeObjStep, target: std.build.Target, lib_type: LibType) void {
    // artifact.addLibPath("aya/deps/soloud");
    // artifact.addObjectFile("aya/deps/soloud/libsoloud_static.a");

    switch (lib_type) {
        .static => {
            const lib = b.addStaticLibrary("soloud", null);
            lib.setBuildMode(builtin.Mode.ReleaseSmall);
            lib.setTarget(target);

            compileSoloud(b, lib, target);
            lib.install();

            artifact.linkLibrary(lib);
        },
        .dynamic => {
            const lib = b.addSharedLibrary("Soloud", null, b.version(0, 0, 1));
            lib.setBuildMode(builtin.Mode.ReleaseSmall);
            lib.setTarget(target);

            compileSoloud(b, lib, target);
            lib.install();

            artifact.linkLibrary(lib);
        },
        .exe_compiled => {
            compileSoloud(b, artifact, target);
        },
    }
}

fn compileSoloud(b: *Builder, exe: *std.build.LibExeObjStep, target: std.build.Target) void {
    exe.linkSystemLibrary("SDL2");
    exe.linkLibC();
    exe.linkSystemLibrary("c++");

    // for builds from the root dir of the project
    exe.addIncludeDir("aya/deps/soloud/soloud/include");

    // for local builds with this build file as the root of the build
    // exe.addIncludeDir("soloud/include");

    const cflags = &[_][]const u8{"-DWITH_SDL2"};

    for (src_files) |src_file| {
        const file = b.fmt("aya/deps/soloud/soloud/src/{}", .{src_file});
        // flor local builds
        // const file = b.fmt("soloud/src/{}", .{src_file});
        exe.addCSourceFile(file, cflags);
    }
}

const src_files = [_][]const u8{
    "audiosource/ay/chipplayer.cpp",
    "audiosource/ay/sndbuffer.cpp",
    "audiosource/ay/sndchip.cpp",
    "audiosource/ay/sndrender.cpp",
    "audiosource/ay/soloud_ay.cpp",
    "audiosource/monotone/soloud_monotone.cpp",
    "audiosource/noise/soloud_noise.cpp",
    "audiosource/openmpt/soloud_openmpt.cpp",
    "audiosource/openmpt/soloud_openmpt_dll.c",
    "audiosource/sfxr/soloud_sfxr.cpp",
    "audiosource/speech/darray.cpp",
    "audiosource/speech/klatt.cpp",
    "audiosource/speech/resonator.cpp",
    "audiosource/speech/soloud_speech.cpp",
    "audiosource/speech/tts.cpp",
    "audiosource/tedsid/sid.cpp",
    "audiosource/tedsid/soloud_tedsid.cpp",
    "audiosource/tedsid/ted.cpp",
    "audiosource/vic/soloud_vic.cpp",
    "audiosource/vizsn/soloud_vizsn.cpp",
    "audiosource/wav/dr_impl.cpp",
    "audiosource/wav/soloud_wav.cpp",
    "audiosource/wav/soloud_wavstream.cpp",
    "audiosource/wav/stb_vorbis.c",

    "backend/sdl/soloud_sdl2.cpp",
    "backend/sdl/soloud_sdl2_dll.c",
    "core/soloud.cpp",
    "core/soloud_audiosource.cpp",
    "core/soloud_bus.cpp",
    "core/soloud_core_3d.cpp",
    "core/soloud_core_basicops.cpp",
    "core/soloud_core_faderops.cpp",
    "core/soloud_core_filterops.cpp",
    "core/soloud_core_getters.cpp",
    "core/soloud_core_voicegroup.cpp",
    "core/soloud_core_voiceops.cpp",
    "core/soloud_fader.cpp",
    "core/soloud_fft.cpp",
    "core/soloud_fft_lut.cpp",
    "core/soloud_file.cpp",
    "core/soloud_filter.cpp",
    "core/soloud_misc.cpp",
    "core/soloud_queue.cpp",
    "core/soloud_thread.cpp",
    "filter/soloud_bassboostfilter.cpp",
    "filter/soloud_biquadresonantfilter.cpp",
    "filter/soloud_dcremovalfilter.cpp",
    "filter/soloud_echofilter.cpp",
    "filter/soloud_eqfilter.cpp",
    "filter/soloud_fftfilter.cpp",
    "filter/soloud_flangerfilter.cpp",
    "filter/soloud_freeverbfilter.cpp",
    "filter/soloud_lofifilter.cpp",
    "filter/soloud_robotizefilter.cpp",
    "filter/soloud_waveshaperfilter.cpp",
    "c_api/soloud_c.cpp",
};
