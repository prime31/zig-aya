const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;
const Pkg = std.build.Pkg;

const fna_build = @import("deps/fna/build.zig");
const sdl_build = @import("deps/sdl/build.zig");
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
    sdl_build.linkArtifact(artifact);
    imgui_build.linkArtifact(b, artifact, target, @intToEnum(imgui_build.LibType, @enumToInt(lib_type)));
    fontstash_build.linkArtifact(b, artifact, target, @intToEnum(fontstash_build.LibType, @enumToInt(lib_type)));

    const sdl = Pkg{
        .name = "sdl",
        .path = "aya/deps/sdl/sdl.zig",
    };
    const fna = Pkg{
        .name = "fna",
        .path = "aya/deps/fna/fna.zig",
        .dependencies = &[_]Pkg{sdl},
    };
    const imgui = Pkg{
        .name = "imgui",
        .path = "aya/deps/imgui/imgui.zig",
    };
    const fontstash = Pkg{
        .name = "fontstash",
        .path = "aya/deps/fontstash/fontstash.zig",
    };
    const aya = Pkg{
        .name = "aya",
        .path = "aya/src/aya.zig",
        .dependencies = &[_]Pkg{sdl, fna, imgui, fontstash},
    };

    // packages exported to userland
    artifact.addPackage(aya);
    artifact.addPackage(sdl);
    artifact.addPackage(imgui);
}

// add tests.zig file runnable via "zig build test"
pub fn addTests(b: *Builder, target: std.build.Target) void {
    var tst = b.addTest("aya/tests.zig");
    linkArtifact(b, tst, target, .exe_compiled);
    const test_step = b.step("test", "Run tests in tests.zig");
    test_step.dependOn(&tst.step);
}
