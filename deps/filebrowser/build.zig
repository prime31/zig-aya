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
    linkArtifact(b, exe, b.standardTargetOptions(.{}), .static, "");
    exe.install();
}

/// rel_path is used to add package paths. It should be the the same path used to include this build file
pub fn linkArtifact(b: *Builder, artifact: *std.build.LibExeObjStep, target: std.build.Target, lib_type: LibType, rel_path: []const u8) void {
    switch (lib_type) {
        .static => {
            const lib = b.addStaticLibrary("FileBrowser", null);
            lib.setBuildMode(builtin.Mode.ReleaseSmall);
            lib.setTarget(target);

            compileFontStash(b, lib, target);
            lib.install();

            artifact.linkLibrary(lib);
        },
        .dynamic => {
            const lib = b.addSharedLibrary("FileBrowser", null, b.version(0, 0, 1));
            lib.setBuildMode(builtin.Mode.ReleaseSmall);
            lib.setTarget(target);

            compileFontStash(b, lib, target);
            lib.install();

            artifact.linkLibrary(lib);
        },
        .exe_compiled => {
            compileFontStash(b, artifact, target);
        },
    }

    // we can leave the zig file in this folder only for filebrowser because it is not used by aya and only by consuming exe's
    artifact.addPackagePath("filebrowser", "deps/filebrowser/filebrowser.zig");
}

fn compileFontStash(b: *Builder, exe: *std.build.LibExeObjStep, target: std.build.Target) void {
    const lib_cflags = &[_][]const u8{"-fPIC"};
    exe.addCSourceFile("deps/filebrowser/src/tinyfiledialogs.c", lib_cflags);
}
