const builtin = @import("builtin");
const std = @import("std");

const LibExeObjStep = std.build.LibExeObjStep;
const Builder = std.build.Builder;
const Target = std.build.Target;
const Pkg = std.build.Pkg;

const renderkit_build = @import("aya/deps/renderkit/build.zig");
const ShaderCompileStep = renderkit_build.ShaderCompileStep;

var enable_imgui: ?bool = null;

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});

    // first item in list will be added as "run" so `zig build run` will always work
    const examples = [_][2][]const u8{
        // [_][]const u8{ "editor", "editor/main.zig" },
        // [_][]const u8{ "mode7", "examples/mode7.zig" },
        // [_][]const u8{ "markov", "examples/markov.zig" },
        // [_][]const u8{ "clipper", "examples/clipped_sprite.zig" },
        // [_][]const u8{ "primitives", "examples/primitives.zig" },
        // [_][]const u8{ "entities", "examples/entities.zig" },
        [_][]const u8{ "shaders", "examples/shaders.zig" },
        // [_][]const u8{ "atlas_batch", "examples/atlas_batch.zig" },
        // [_][]const u8{ "tilemap", "examples/tilemap.zig" },
        // [_][]const u8{ "fonts", "examples/fonts.zig" },
        // [_][]const u8{ "batcher", "examples/batcher.zig" },
        [_][]const u8{ "offscreen", "examples/offscreen.zig" },
        [_][]const u8{ "dynamic_mesh", "examples/dynamic_mesh.zig" },
        [_][]const u8{ "instanced_mesh", "examples/instanced_mesh.zig" },
        [_][]const u8{ "mesh", "examples/mesh.zig" },
        [_][]const u8{ "imgui", "examples/imgui.zig" },
        [_][]const u8{ "empty", "examples/empty.zig" },
    };

    const examples_step = b.step("examples", "build all examples");
    b.default_step.dependOn(examples_step);

    for (examples) |example, i| {
        var exe = createExe(b, target, example[0], example[1]);
        examples_step.dependOn(&exe.step);

        // first element in the list is added as "run" so "zig build run" works
        if (i == 0) _ = createExe(b, target, "run", example[1]);
    }

    // shader compiler, run with `zig build compile-shaders`
    const res = ShaderCompileStep.init(b, "aya/deps/renderkit/shader_compiler/", .{
        .shader = "examples/assets/shaders/shader_src.glsl",
        .shader_output_path = "examples/assets/shaders",
        .package_output_path = "examples/assets/shaders",
        .additional_imports = &[_][]const u8{
            "const aya = @import(\"aya\");",
            "const gfx = aya.gfx;",
            "const math = aya.math;",
            "const renderkit = aya.renderkit;",
        },
    });

    const comple_shaders_step = b.step("compile-shaders", "compiles all shaders");
    b.default_step.dependOn(comple_shaders_step);
    comple_shaders_step.dependOn(&res.step);

    addTests(b, target, "");
}

/// creates an exe with all the required dependencies
fn createExe(b: *Builder, target: Target, name: []const u8, source: []const u8) *std.build.LibExeObjStep {
    var exe = b.addExecutable(name, source);
    exe.setBuildMode(b.standardReleaseOptions());
    exe.setOutputDir("zig-cache/bin");

    addAyaToArtifact(b, exe, target, "");

    const run_cmd = exe.run();
    const exe_step = b.step(name, b.fmt("run {}.zig", .{name}));
    exe_step.dependOn(&run_cmd.step);

    return exe;
}

/// adds Aya and all dependencies to artifact
pub fn addAyaToArtifact(b: *Builder, artifact: *std.build.LibExeObjStep, target: std.build.Target, comptime prefix_path: []const u8) void {
    // only add the build option once!
    if (enable_imgui == null)
        enable_imgui = b.option(bool, "imgui", "enable imgui") orelse false;
    artifact.addBuildOption(bool, "enable_imgui", enable_imgui.?);

    // STB Image, Image Write, Rect Pack
    const stb_build = @import("aya/deps/stb/build.zig");
    stb_build.linkArtifact(b, artifact, target, prefix_path);
    const stb_pkg = stb_build.getPackage(prefix_path);

    // FontStash
    const fontstash_build = @import("aya/deps/fontstash/build.zig");
    fontstash_build.linkArtifact(b, artifact, target, prefix_path);
    const fontstash_pkg = fontstash_build.getPackage(prefix_path);

    // Dear ImGui
    // TODO: skip adding imgui altogether when enable_imgui is false. This would require builds to be made with -Denable_imgui=true
    const imgui_build = @import("aya/deps/imgui/build.zig");
    imgui_build.linkArtifact(b, artifact, target, prefix_path);
    const imgui_pkg = imgui_build.getImGuiPackage(prefix_path);
    const imgui_gl_pkg = imgui_build.getImGuiGlPackage(prefix_path);

    // RenderKit
    renderkit_build.addRenderKitToArtifact(b, artifact, target, prefix_path ++ "aya/deps/renderkit/");
    const renderkit_pkg = renderkit_build.getRenderKitPackage(prefix_path ++ "aya/deps/renderkit/");

    // SDL
    const sdl_build = @import("aya/deps/sdl/build.zig");
    sdl_build.linkArtifact(b, artifact, target, prefix_path);
    const sdl_pkg = sdl_build.getPackage(prefix_path);


    const aya = Pkg{
        .name = "aya",
        .path = "aya/aya.zig",
        .dependencies = &[_]Pkg{ renderkit_pkg, sdl_pkg, stb_pkg, fontstash_pkg, imgui_pkg, imgui_gl_pkg },
    };

    // export aya to userland
    artifact.addPackage(aya);
}

// add tests.zig file runnable via "zig build test"
pub fn addTests(b: *Builder, target: Target, comptime prefix_path: []const u8) void {
    var tst = b.addTest(prefix_path ++ "aya/tests.zig");
    addAyaToArtifact(b, tst, target, prefix_path);
    const test_step = b.step("test", "Run tests in tests.zig");
    test_step.dependOn(&tst.step);
}
