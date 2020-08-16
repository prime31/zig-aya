const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;

const aya_build = @import("aya/build.zig");

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});

    // ImGui requires `pub const imgui = true;` in the root file and `include_imgui` to be true so it is compiled in
    var include_imgui = false;

    // first item in list will be added as "run" so `zig build run` will always work
    const examples = [_][2][]const u8{
        [_][]const u8{ "clipper", "examples/clipped_sprite.zig" },
        [_][]const u8{ "primitives", "examples/primitives.zig" },
        [_][]const u8{ "entities", "examples/entities.zig" },
        [_][]const u8{ "shaders", "examples/shaders.zig" },
        [_][]const u8{ "atlas_batch", "examples/atlas_batch.zig" },
        [_][]const u8{ "tilemap", "examples/tilemap.zig" },
        [_][]const u8{ "fonts", "examples/fonts.zig" },
        [_][]const u8{ "batcher", "examples/batcher.zig" },
        [_][]const u8{ "offscreen", "examples/offscreen.zig" },
        [_][]const u8{ "dynamic_mesh", "examples/dynamic_mesh.zig" },
        [_][]const u8{ "mesh", "examples/mesh.zig" },
        [_][]const u8{ "empty", "examples/empty.zig" },
        [_][]const u8{ "imgui", "examples/imgui.zig" },
        // 3D junk
        [_][]const u8{ "spinning_cubes", "examples/spinning_cubes.zig" },
        [_][]const u8{ "cubes", "examples/cubes.zig" },
        [_][]const u8{ "cube", "examples/cube.zig" },
        [_][]const u8{ "instancing", "examples/instancing.zig" },
    };

    for (examples) |example, i| {
        include_imgui = std.mem.eql(u8, example[0], "imgui") or std.mem.eql(u8, example[0], "shaders") or std.mem.eql(u8, example[0], "clipper") or std.mem.eql(u8, example[0], "cubes") or std.mem.eql(u8, example[0], "spinning_cubes");
        // include_imgui = true;
        createExe(b, target, example[0], example[1], include_imgui);

        // first element in the list is added as "run" so "zig build run" works
        if (i == 0) {
            createExe(b, target, "run", example[1], include_imgui);
        }
    }

    aya_build.addTests(b, target);
    aya_build.addBuildShaders(b, target);
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
