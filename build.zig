const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;

const aya_build = @import("aya/build.zig");

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});

    // windows static lib compilation of FNA causes an SDL header issue so its forced as exe_compiled
    var lib_type = b.option(i32, "lib_type", "0: static, 1: dynamic, 2: exe compiled") orelse 0;
    if (target.isWindows()) lib_type = 2;

    // first item in list will be added as "run" so `zig build run` will always work
    const examples = [_][2][]const u8{
        [_][]const u8{ "tilekit", "examples/tilekit/index.zig" },
        [_][]const u8{ "soloud", "examples/soloud.zig" },
        [_][]const u8{ "tilemap", "examples/tilemap.zig" },
        [_][]const u8{ "shaders", "examples/shaders.zig" },
        [_][]const u8{ "imgui", "examples/imgui.zig" },
        [_][]const u8{ "empty", "examples/empty.zig" },
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

    aya_build.addTests(b, target);
}

// creates an exe with all the required dependencies
fn createExe(b: *Builder, target: std.build.Target, lib_type: i32, name: []const u8, source: []const u8) void {
    var exe = b.addExecutable(name, source);
    exe.setBuildMode(b.standardReleaseOptions());
    exe.setOutputDir("zig-cache/bin");

    aya_build.linkArtifact(b, exe, target, @intToEnum(aya_build.LibType, lib_type));

    // these dont seem to work yet? Should be able to get at them with: const build_options = @import("build_options");
    // for these to work we need the following:
    // in main.zig: pub const build_options = @import("build_options");
    // in aya.zig: pub const build_options = @import("root").build_options;
    exe.addBuildOption(bool, "debug", true);

    // dependencies only required for tilekit
    if (std.mem.eql(u8, name, "tilekit") or std.mem.endsWith(u8, source, "index.zig")) {
        const filebrowser_build = @import("deps/filebrowser/build.zig");
        filebrowser_build.linkArtifact(b, exe, target, @intToEnum(filebrowser_build.LibType, lib_type), "deps/filebrowser");

        const stb_image_build = @import("deps/stb_image/build.zig");
        stb_image_build.linkArtifact(b, exe, target, @intToEnum(stb_image_build.LibType, lib_type), "deps/stb_image");
    }

    const run_cmd = exe.run();
    const exe_step = b.step(name, b.fmt("run {}.zig", .{name}));
    exe_step.dependOn(&run_cmd.step);
}

