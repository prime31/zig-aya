const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;
const Pkg = std.build.Pkg;

const fna_build = @import("deps/fna/build.zig");
const imgui_build = @import("deps/imgui/build.zig");
const fontstash_build = @import("deps/fontstash/build.zig");

pub const LibType = enum(i32) {
    static,
    dynamic, // requires DYLD_LIBRARY_PATH to point to the dylib path
    exe_compiled,
};

pub fn linkArtifact(b: *Builder, artifact: *std.build.LibExeObjStep, target: std.build.Target, lib_type: LibType) void {
    // fna can be dynamic, static or compiled in
    fna_build.linkArtifact(b, artifact, target, @intToEnum(fna_build.LibType, @enumToInt(lib_type)));
    imgui_build.linkArtifact(b, artifact, target, @intToEnum(imgui_build.LibType, @enumToInt(lib_type)));
    fontstash_build.linkArtifact(b, artifact, target, @intToEnum(fontstash_build.LibType, @enumToInt(lib_type)));

    // move to SDL dep
    artifact.linkSystemLibrary("c");
    artifact.linkSystemLibrary("SDL2");


    var sdl = Pkg{
        .name = "sdl",
        .path = "aya/src/deps/sdl/sdl.zig",
    };
    var imgui = Pkg{
        .name = "imgui",
        .path = "aya/src/deps/imgui/imgui.zig",
    };
    // var fontstash = Pkg{
    //     .name = "fontstash",
    //     .path = "aya/src/deps/fontstash/fontstash.zig",
    // };
    var aya = Pkg{
        .name = "aya",
        .path = "aya/src/aya.zig",
        .dependencies = &[_]Pkg{}, // TODO: doesnt work!! crashes the compiler
    };

    artifact.addPackage(sdl);
    artifact.addPackage(imgui);
    artifact.addPackage(aya);
}

// add tests.zig file runnable via "zig build test"
pub fn addTests(b: *Builder, target: std.build.Target) void {
    var t = b.addTest("aya/tests.zig");
    linkArtifact(b, t, target, .exe_compiled);
    const test_step = b.step("test", "Run tests in tests.zig");
    test_step.dependOn(&t.step);
}