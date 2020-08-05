const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;
const Pkg = std.build.Pkg;

const sokol_build = @import("deps/sokol/build.zig");
const imgui_build = @import("deps/imgui/build.zig");
const stb_image_build = @import("deps/stb_image/build.zig");
const fontstash_build = @import("deps/fontstash/build.zig");

pub fn linkArtifact(b: *Builder, artifact: *std.build.LibExeObjStep, target: std.build.Target, include_imgui: bool) void {
    sokol_build.linkArtifact(b, artifact, target, include_imgui);
    stb_image_build.linkArtifact(b, artifact, target);
    fontstash_build.linkArtifact(b, artifact, target);

    if (include_imgui) {
        imgui_build.linkArtifact(b, artifact, target);
    }

    const sokol = Pkg{
        .name = "sokol",
        .path = "aya/deps/sokol/sokol.zig",
    };
    const imgui = Pkg{
        .name = "imgui",
        .path = "aya/deps/imgui/imgui.zig",
    };
    const stb_image = Pkg{
        .name = "stb_image",
        .path = "aya/deps/stb_image/stb_image.zig",
    };
    const fontstash = Pkg{
        .name = "fontstash",
        .path = "aya/deps/fontstash/fontstash.zig",
    };
    const shaders = Pkg{
        .name = "shaders",
        .path = "aya/shaders/shaders.zig",
        .dependencies = &[_]Pkg{sokol},
    };
    const aya = Pkg{
        .name = "aya",
        .path = "aya/src/aya.zig",
        .dependencies = &[_]Pkg{sokol, imgui, stb_image, fontstash, shaders},
    };

    // packages exported to userland
    artifact.addPackage(sokol);
    artifact.addPackage(imgui);
    artifact.addPackage(aya);
    artifact.addPackage(shaders);

    // shaders
    artifact.addIncludeDir("aya/shaders");
    artifact.addCSourceFile("aya/shaders/basics.c", &[_][]const u8{"-std=c99"});
}

// add tests.zig file runnable via "zig build test"
pub fn addTests(b: *Builder, target: std.build.Target) void {
    var tst = b.addTest("aya/tests.zig");
    linkArtifact(b, tst, target, false);
    const test_step = b.step("test", "Run tests in tests.zig");
    test_step.dependOn(&tst.step);
}
