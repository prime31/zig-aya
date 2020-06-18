const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;

const fna_build = @import("deps/fna/build.zig");
const imgui_build = @import("deps/imgui/build.zig");
const fontstash_build = @import("deps/fontstash/build.zig");

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});

    // windows static lib compilation of FNA causes an SDL header issue so its forced as exe_compiled
    var lib_type = b.option(i32, "lib_type", "0: static, 1: dynamic, 2: exe compiled") orelse 0;
    if (target.isWindows()) lib_type = 2;

    // first item in list will be added as "run" so `zig build run` will always work
    const examples = [_][2][]const u8{
        [_][]const u8{ "imgui", "examples/imgui.zig" },
        [_][]const u8{ "imgui", "examples/empty.zig" },
        [_][]const u8{ "offscreen", "examples/offscreen.zig" },
        [_][]const u8{ "fonts", "examples/fonts.zig" },
        [_][]const u8{ "main", "examples/main.zig" },
        [_][]const u8{ "mesh", "examples/mesh.zig" },
        [_][]const u8{ "batcher", "examples/batcher.zig" },
        [_][]const u8{ "atlas_batch", "examples/atlas_batch.zig" },
        [_][]const u8{ "primitives", "examples/primitives.zig" },
    };

    for (examples) |example, i| {
        createExe(b, target, lib_type, example[0], example[1]);

        // first element in the list is added as "run" so "zig build run" works
        if (i == 0) {
            createExe(b, target, lib_type, "run", example[1]);
        }
    }

    addTests(b, target);
}

// creates an exe with all the required dependencies
fn createExe(b: *Builder, target: std.build.Target, lib_type: i32, name: []const u8, source: []const u8) void {
    var exe = b.addExecutable(name, source);
    exe.setBuildMode(b.standardReleaseOptions());

    // these dont seem to work yet? Should be able to get at them with: const build_options = @import("build_options");
    // for these to work we need the following:
    // in main.zig: pub const build_options = @import("build_options");
    // in aya.zig: pub const build_options = @import("root").build_options;
    exe.addBuildOption(bool, "debug", true);

    exe.addPackagePath("aya", "src/aya.zig");
    exe.addPackagePath("sdl", "src/deps/sdl/sdl.zig");

    // fna can be dynamic, static or compiled in
    fna_build.linkArtifact(b, exe, target, @intToEnum(fna_build.LibType, lib_type), "src/deps/fna");
    imgui_build.linkArtifact(b, exe, target, @intToEnum(imgui_build.LibType, lib_type), "src/deps/imgui");
    fontstash_build.linkArtifact(b, exe, target, @intToEnum(fontstash_build.LibType, lib_type), "src/deps/fontstash");

    exe.linkSystemLibrary("c");
    exe.linkSystemLibrary("SDL2");

    const run_cmd = exe.run();
    const exe_step = b.step(name, b.fmt("run {}.zig", .{name}));
    exe_step.dependOn(&run_cmd.step);
}

// add tests.zig file runnable via "zig build test"
fn addTests(b: *Builder, target: std.build.Target) void {
    var t = b.addTest("tests.zig");
    t.addPackagePath("aya", "src/aya.zig");
    t.addPackagePath("sdl", "src/deps/sdl/sdl.zig");

    fna_build.linkArtifact(b, t, target, .exe_compiled, "src/deps/fna");
    fontstash_build.linkArtifact(b, t, target, .exe_compiled, "src/deps/fontstash");

    t.linkSystemLibrary("c");
    t.linkSystemLibrary("SDL2");

    const test_step = b.step("test", "Run tests in tests.zig");
    test_step.dependOn(&t.step);
}
