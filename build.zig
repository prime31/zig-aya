const builtin = @import("builtin");
const std = @import("std");

const LibExeObjStep = std.build.LibExeObjStep;
const Builder = std.build.Builder;
const Target = std.build.Target;
const Pkg = std.build.Pkg;

const renderkit_build = @import("aya/deps/renderkit/build.zig");
const sdl_build = @import("aya/deps/sdl/build.zig");
const imgui_build = @import("aya/deps/imgui/build.zig");
const stb_build = @import("aya/deps/stb/build.zig");
const fontstash_build = @import("aya/deps/fontstash/build.zig");

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});

    // ImGui requires `pub const imgui = true;` in the root file and `include_imgui` to be true so it is compiled in
    var include_imgui = false;

    // first item in list will be added as "run" so `zig build run` will always work
    const examples = [_][2][]const u8{
        // [_][]const u8{ "empty", "examples/empty.zig" },
        // [_][]const u8{ "editor", "editor/main.zig" },
        // [_][]const u8{ "mode7", "examples/mode7.zig" },
        // [_][]const u8{ "markov", "examples/markov.zig" },
        // [_][]const u8{ "clipper", "examples/clipped_sprite.zig" },
        // [_][]const u8{ "primitives", "examples/primitives.zig" },
        // [_][]const u8{ "entities", "examples/entities.zig" },
        // [_][]const u8{ "shaders", "examples/shaders.zig" },
        // [_][]const u8{ "atlas_batch", "examples/atlas_batch.zig" },
        // [_][]const u8{ "tilemap", "examples/tilemap.zig" },
        // [_][]const u8{ "fonts", "examples/fonts.zig" },
        // [_][]const u8{ "batcher", "examples/batcher.zig" },
        // [_][]const u8{ "offscreen", "examples/offscreen.zig" },
        [_][]const u8{ "dynamic_mesh", "examples/dynamic_mesh.zig" },
        [_][]const u8{ "mesh", "examples/mesh.zig" },
        [_][]const u8{ "imgui", "examples/imgui.zig" },
    };

    for (examples) |example, i| {
        include_imgui = true;
        createExe(b, target, example[0], example[1], include_imgui);

        // first element in the list is added as "run" so "zig build run" works
        if (i == 0) {
            createExe(b, target, "run", example[1], include_imgui);
        }
    }

    addTests(b, target, "");
}

/// creates an exe with all the required dependencies
fn createExe(b: *Builder, target: Target, name: []const u8, source: []const u8, include_imgui: bool) void {
    var exe = b.addExecutable(name, source);
    exe.setBuildMode(b.standardReleaseOptions());
    exe.setOutputDir("zig-cache/bin");

    addAyaToArtifact(b, exe, target, include_imgui, "");

    const run_cmd = exe.run();
    const exe_step = b.step(name, b.fmt("run {}.zig", .{name}));
    exe_step.dependOn(&run_cmd.step);
}

/// adds Aya and all dependencies to artifact
pub fn addAyaToArtifact(b: *Builder, artifact: *std.build.LibExeObjStep, target: std.build.Target, include_imgui: bool, comptime prefix_path: []const u8) void {
    stb_build.linkArtifact(b, artifact, target, prefix_path);
    fontstash_build.linkArtifact(b, artifact, target, prefix_path);

    if (include_imgui) {
        imgui_build.linkArtifact(b, artifact, target, prefix_path);
    }

    renderkit_build.addRenderKitToArtifact(b, artifact, target, prefix_path ++ "aya/deps/renderkit/");
    const renderkit_pkg = renderkit_build.getRenderKitPackage(prefix_path ++ "aya/deps/renderkit/");

    sdl_build.linkArtifact(artifact, target, prefix_path);
    const sdl_pkg = sdl_build.getPackage(prefix_path);

    const imgui_pkg = imgui_build.getImGuiPackage(prefix_path);
    const stb_pkg = stb_build.getPackage(prefix_path);
    const fontstash_pkg = fontstash_build.getPackage(prefix_path);

    const aya = Pkg{
        .name = "aya",
        .path = "aya/aya.zig",
        .dependencies = &[_]Pkg{renderkit_pkg, sdl_pkg, stb_pkg, fontstash_pkg, imgui_pkg},
    };

    // packages exported to userland
    artifact.addPackage(imgui_pkg);
    artifact.addPackage(stb_pkg);
    artifact.addPackage(fontstash_pkg);
    artifact.addPackage(aya);
}

// add tests.zig file runnable via "zig build test"
pub fn addTests(b: *Builder, target: Target, comptime prefix_path: []const u8) void {
    var tst = b.addTest(prefix_path ++ "aya/tests.zig");
    addAyaToArtifact(b, tst, target, false, prefix_path);
    const test_step = b.step("test", "Run tests in tests.zig");
    test_step.dependOn(&tst.step);
}
