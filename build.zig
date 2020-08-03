const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;

const aya_build = @import("aya/build.zig");

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});
    const include_imgui = false;

    // first item in list will be added as "run" so `zig build run` will always work
    const examples = [_][2][]const u8{
        [_][]const u8{ "mesh", "examples/dynamic_mesh.zig" },
        [_][]const u8{ "mesh", "examples/mesh.zig" },
        [_][]const u8{ "empty", "examples/empty.zig" },

        // [_][]const u8{ "tilemap", "examples/tilemap.zig" },
        // [_][]const u8{ "shaders", "examples/shaders.zig" },
        // [_][]const u8{ "imgui", "examples/imgui.zig" },
        // [_][]const u8{ "offscreen", "examples/offscreen.zig" },
        // [_][]const u8{ "fonts", "examples/fonts.zig" },
        // [_][]const u8{ "main", "examples/main.zig" },
        // [_][]const u8{ "batcher", "examples/batcher.zig" },
        // [_][]const u8{ "atlas_batch", "examples/atlas_batch.zig" },
        // [_][]const u8{ "primitives", "examples/primitives.zig" },
    };

    for (examples) |example, i| {
        createExe(b, target, example[0], example[1], include_imgui);

        // first element in the list is added as "run" so "zig build run" works
        if (i == 0) {
            createExe(b, target, "run", example[1], include_imgui);
        }
    }

    aya_build.addTests(b, target);
}

// creates an exe with all the required dependencies
fn createExe(b: *Builder, target: std.build.Target, name: []const u8, source: []const u8, include_imgui: bool) void {
    var exe = b.addExecutable(name, source);
    exe.setBuildMode(b.standardReleaseOptions());
    exe.setOutputDir("zig-cache/bin");

    aya_build.linkArtifact(b, exe, target, include_imgui);

    const run_cmd = exe.run();
    const exe_step = b.step(name, b.fmt("run {}.zig", .{name}));
    exe_step.dependOn(&run_cmd.step);
}

